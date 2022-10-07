function [statsTable,numRepCols,numDataCols]=generateStatsTable(fig,Stats,tableName)

%% PURPOSE: CREATE THE STATS TABLE IN AN EXCEL FILE AND MATLAB MATRIX.
handles=getappdata(fig,'handles');
VariableNamesList=getappdata(fig,'VariableNamesList');

%% Get the names & split codes of the rep vars
repVars={Stats.Tables.(tableName).RepetitionColumns.Name};
% varNames=cell(size(repVars));
% varCodes=cell(size(repVars));
varNamesInFile=cell(size(repVars));
for i=1:length(repVars)    
    spaceIdx=strfind(repVars{i},' ');
    varName=repVars{i}(1:spaceIdx(end)-1);
    varCode=repVars{i}(spaceIdx(end)+2:end-1);
    varIdx=ismember(VariableNamesList.GUINames,varName);
    varSaveName=VariableNamesList.SaveNames{varIdx};
    varNamesInFile{i}=[varSaveName '_' varCode];
end

numRepCols=length(varNamesInFile);

%% Get the names & split codes of the data vars
dataVars={Stats.Tables.(tableName).DataColumns.Name};
% varNames=cell(size(dataVars));
fcnNames=cell(size(dataVars));
for i=1:length(dataVars)    
%     spaceIdx=strfind(dataVars{i},' ');
%     varNames{i}=dataVars{i}(1:spaceIdx-1);
%     varCodes{i}=dataVars{i}(spaceIdx+2:end-1);
    fcnNames{i}=[Stats.Tables.(tableName).DataColumns(i).Function '_Stats'];
end

numDataCols=length(fcnNames);

statsFcnPath=[getappdata(fig,'codePath') 'Statistics'];

oldPath=cd(statsFcnPath);

specifyTrialsName=Stats.Tables.(tableName).SpecifyTrials;
inclStruct=feval(specifyTrialsName);
load(getappdata(fig,'logsheetPathMAT'),'logVar');
allTrialNames=getTrialNames(inclStruct,logVar,fig,0,[]);

%% Initialize the stats table
subNames=fieldnames(allTrialNames);
numRows=0;
for sub=1:length(subNames)

    subName=subNames{sub};
    trialFldNames=fieldnames(allTrialNames.(subName));
    for trialNum=1:length(trialFldNames)

        trialName=trialFldNames{trialNum};

        for repNum=allTrialNames.(subName).(trialName)
            numRows=numRows+1;
        end

    end

end

% The plus one is for the trial number between the repetition and data columns. The other plus one is for the trial name all the way to the left.
numCols=length(fcnNames)+length(varNamesInFile)+2;

statsTable=cell(numRows,numCols);

%% Organize the repetition columns
slash=filesep;
projectName=getappdata(fig,'projectName');
rowNum=0;
for sub=1:length(subNames)

    subName=subNames{sub};
    trialFldNames=fieldnames(allTrialNames.(subName));
    subFileName=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];    

    for trialNum=1:length(trialFldNames)

        trialName=trialFldNames{trialNum};

        for repNum=allTrialNames.(subName).(trialName)

            trialFileName=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
            warning('off','MATLAB:load:variableNotFound');
            load(trialFileName,varNamesInFile{:});
            a=whos;
            a={a.name};
            varNamesNotInFile=varNamesInFile(~ismember(varNamesInFile,a));
            if ~isempty(varNamesNotInFile)
                load(subFileName,varNamesNotInFile{:}); % Load subject level variables
            end
            warning('on','MATLAB:load:variableNotFound');
            a=whos;
            a={a.name};
            varNamesNotInFile=varNamesNotInFile(~ismember(varNamesNotInFile,a));
            if ~isempty(varNamesNotInFile)
                error(['Missing variables: ' varNamesNotInFile{:}]);
            end
            var=cell(length(varNamesInFile),1);            
            for i=1:length(varNamesInFile)     
                var{i}=eval(varNamesInFile{i});
            end

            % Insert the data into proper row & column
            rowNum=rowNum+1;
            for colNum=1:length(var) % To avoid overwriting the trial name column all the way to the left
                statsTable{rowNum,colNum+1}=var{colNum};
            end       

            for i=1:length(varNamesInFile)
                clearvars(varNamesInFile{i});
            end

        end

    end

end

%% Put data into the data columns
rowNum=0;
minColNum=length(varNamesInFile)+2; % +1 for the trial number, the other +1 for the trial name
setappdata(fig,'tableName',tableName);
for sub=1:length(subNames)

    subName=subNames{sub};
    trialFldNames=fieldnames(allTrialNames.(subName)); 

    for trialNum=1:length(trialFldNames)

        trialName=trialFldNames{trialNum};

        for repNum=allTrialNames.(subName).(trialName)

            rowNum=rowNum+1;
            for i=1:length(fcnNames)

                fcnName=fcnNames{i};
                setappdata(fig,'fcnName',fcnName);
                setappdata(fig,'fcnIdx',i);
                [data]=feval(fcnName,[],subName,trialName,repNum);
                colNum=minColNum+i;

                statsTable{rowNum,colNum}=data;

            end

        end

    end

end

cd(oldPath);

%% Prepend the trial name column
% If the checkbox to retain this is selected
subNames=fieldnames(allTrialNames);
rowNum=0;
for sub=1:length(subNames)

    subName=subNames{sub};
    trialFldNames=fieldnames(allTrialNames.(subName));
    for trialNum=1:length(trialFldNames)

        trialName=trialFldNames{trialNum};

        for repNum=allTrialNames.(subName).(trialName)
            rowNum=rowNum+1;
            statsTable{rowNum,1}=trialName;
        end

    end

end

%% Rearrange the stats table so that the repetitions are in blocks, incrementing from left to right (e.g. all trials of one subject clumped together, then all trials of one condition)
% origTable=statsTable;
% for colNum=2:numRepCols+1
%     uniqueEntries=unique(statsTable(:,colNum));
%     prevEntryRows=0;
% 
%     for i=1:length(uniqueEntries)
% 
%         entryRows=find(ismember(statsTable(:,colNum),uniqueEntries{i})==1);
%         newTable2(prevEntryRows+1:prevEntryRows+length(entryRows),1:size(statsTable,2))=origTable(entryRows,:);
% 
%         prevEntryRows=size(newTable2,1);
% 
%     end
% 
%     newTable=newTable2;
%     clear newTable2;
% 
% end

%% Add in the trial number now that everything is in the proper order
