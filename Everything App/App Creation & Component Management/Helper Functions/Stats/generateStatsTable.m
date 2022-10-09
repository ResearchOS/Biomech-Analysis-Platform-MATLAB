function [statsTable,numRepCols,numDataCols,repVars,dataVarNames]=generateStatsTable(fig,Stats,tableName)

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
dataVarNames=fcnNames;
for i=1:length(dataVars)    
%     spaceIdx=strfind(dataVars{i},' ');
%     varNames{i}=dataVars{i}(1:spaceIdx-1);
%     varCodes{i}=dataVars{i}(spaceIdx+2:end-1);
    fcnNames{i}=[Stats.Tables.(tableName).DataColumns(i).Function '_Stats'];
    dataVarNames{i}=[dataVars{i} '_' Stats.Tables.(tableName).DataColumns(i).Function];
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
for colNum=numRepCols+1:-1:2
    [~,sortIdx]=sort(statsTable(:,colNum));
    statsTable=statsTable(sortIdx,:);
end

%% Add in the trial number now that everything is in the proper order
trialNumCol=numRepCols+2;
uniqueEntries=unique(statsTable(:,trialNumCol-1)); % Last repetition variable column
maxEntriesNum=0;

for i=1:length(uniqueEntries)

    entryIdx=ismember(statsTable(:,trialNumCol-1),uniqueEntries{i}); % 1 where the current entry is

    entriesDiff=diff([0; entryIdx; 0]); % 1 where the current entry starts, -1 where it ends
    entriesStart=find(entriesDiff==1); % The indices where the current entry starts
    entriesEnd=find(entriesDiff==-1)-1; % -1 to account for the additional zero at the start/end

    assert(isequal(length(entriesStart),length(entriesEnd)));

    for j=1:length(entriesStart)

        if entriesEnd(j)-entriesStart(j)+1>maxEntriesNum
            maxEntriesNum=entriesEnd(j)-entriesStart(j)+1; % The number of repetitions to ensure that every rep block has
        end

        for k=1:entriesEnd(j)-entriesStart(j)+1
            statsTable{entriesStart(j)+k-1,trialNumCol}=k; % Add the number
        end

    end

end

%% Ensure that all conditions have the same number of repetitions
for i=1:length(uniqueEntries)

    entryIdx=ismember(statsTable(:,trialNumCol-1),uniqueEntries{i}); % 1 where the current entry is

    entriesDiff=diff([0; entryIdx; 0]); % 1 where the current entry starts, -1 where it ends
    entriesStart=find(entriesDiff==1); % The indices where the current entry starts
    entriesEnd=find(entriesDiff==-1)-1; % -1 to account for the additional zero at the start/end

    assert(isequal(length(entriesStart),length(entriesEnd)));

    for j=1:length(entriesStart)

        if entriesEnd(j)-entriesStart(j)+1>maxEntriesNum
            error('Logic error! How are there more entries than the max?');
        end

        if entriesEnd(j)-entriesStart(j)+1==maxEntriesNum
            continue;
        end

        % Need to pad the table with entries to ensure that they are all the same length
        numExistReps=entriesEnd(j)-entriesStart(j)+1;
        numRows=maxEntriesNum-numExistReps; % The number of rows to add to the table

        % Determine if repetition & data variables are chars or numeric
        insertData=cell(size(statsTable,2),1);
        for k=2:trialNumCol-1
            if all(cellfun(@isnumeric,statsTable(:,k)))
                insertData{k}=NaN;
            elseif all(cellfun(@ischar,statsTable(:,k)))
                insertData{k}='NaN';
            else
                error(['Mixed chars & numeric in table row ' num2str(k)]);
            end
        end

        for k=trialNumCol+1:size(statsTable,2)
            if all(cellfun(@isnumeric,statsTable(:,k)))
                insertData{k}=NaN;
            elseif all(cellfun(@ischar,statsTable(:,k)))
                insertData{k}='NaN';
            else
                error(['Mixed chars & numeric in table row ' num2str(k)]);
            end
        end

        statsTable=[statsTable(1:entriesStart(j)+numExistReps-1,:); cell(numRows,size(statsTable,2)); statsTable(entriesStart(j)+numExistReps:end,:)];

        entriesEnd(j)=entriesEnd(j)+numRows;

        statsTable(entriesStart(j)+numExistReps:entriesEnd(j),1)={'Missing'}; % Trial name

        for k=2:trialNumCol-1
            statsTable(entriesStart(j)+numExistReps:entriesEnd(j),k)=insertData(k); % Repetition variables
        end
        for k=trialNumCol+1:size(statsTable,2)
            statsTable(entriesStart(j)+numExistReps:entriesEnd(j),k)=insertData(k); % Data variables
        end

        for k=1:numRows
            statsTable{entriesStart(j)+numExistReps+k-1,trialNumCol}=numExistReps+k;
        end

    end

end