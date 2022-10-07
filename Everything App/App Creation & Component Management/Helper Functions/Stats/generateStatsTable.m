function [statsTable]=generateStatsTable(fig,Stats,tableName)

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

numCols=length(fcnNames)+length(varNamesInFile)+1; % The plus one is for the trial number 

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
            for colNum=1:length(var)
                statsTable{rowNum,colNum}=var{colNum};
            end       

            for i=1:length(varNamesInFile)
                clearvars(varNamesInFile{i});
            end

        end

    end

end

%% Put data into the data columns
rowNum=0;
minColNum=length(varNamesInFile)+1; % +1 for the trial number
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