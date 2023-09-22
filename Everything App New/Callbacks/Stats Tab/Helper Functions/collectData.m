function [allTable,numericColIdx]=collectData(metaVarNames,varNames,specifyTrials,multiVar,dims)

%% PURPOSE: PULL THE DATA TOGETHER INTO A TABLE TO ANALYZE.

isMulti=true;
if isempty(multiVar)
    isMulti=false;
    multiVar={''};
end

inclStruct=getInclStruct(specifyTrials);
logUUID = 'LG71F125_74F';
logStruct = loadJSON(logUUID);
% logText='YA_All_Spr21TWW_18F869';
% logPath=getClassFilePath(logText,'Logsheet');
% logStruct=loadJSON(logPath);
computerID=getComputerID();
structPath=logStruct.Logsheet_Path.(computerID);
[folder,file,ext]=fileparts(structPath);
structPathMAT=[folder filesep file '.mat'];
load(structPathMAT,'logVar');
allTrialNames=getTrialNames(inclStruct,logVar,0,logStruct);

%% Get the number of rows in the table.
disp('Get the number of rows in the table');
subNames=fieldnames(allTrialNames);
numRows=0;
tableTrialNames={};
trialSubNames={};
multiVarNames={};
nMulti=length(multiVar);
for sub=1:length(subNames)

    subName=subNames{sub};
    trialFldNames=fieldnames(allTrialNames.(subName));
    for trialNum=1:length(trialFldNames)

        trialName=trialFldNames{trialNum};

        for repNum=allTrialNames.(subName).(trialName)

            for multNum=1:nMulti
                numRows=numRows+1;
                trialSubNames=[trialSubNames; subName];
                tableTrialNames=[tableTrialNames; trialName];
                multiVarNames=[multiVarNames; multiVar{multNum}];
            end
        end

    end

end

%% Put the variables into the table.
disp('Put the variables into the table')
dataPath=getCurrent('Data_Path');
if ~isempty(multiVarNames)
    allTable=[tableTrialNames trialSubNames];
else
    allTable=[tableTrialNames trialSubNames];
    multiVarNames=cell(size(tableTrialNames));
end
startColNum=size(allTable,2);
rowNum=0;
multiVarCol=startColNum+length(metaVarNames)+1;
if ~isMulti
    multiVarCol=multiVarCol-1;
end
for i=1:length(tableTrialNames)

    rowNum=rowNum+1;
    disp(num2str(rowNum));
    trialName=tableTrialNames{i};
    subName=trialSubNames{i};
    multiVarCurr=multiVarNames{i};

    for j=1:length(metaVarNames)
        try
            data=loadMAT(dataPath,metaVarNames{j},subName,trialName);
        catch
            data=loadMAT(dataPath,metaVarNames{j},subName);
        end

        if isfield(data,'All')
            data=data.All;
        elseif isfield(data,'Average')
            data=data.Average;
        end

        if ~isempty(multiVarCurr) && isfield(data,multiVarCurr)
            allTable{rowNum,startColNum+j}=data.(multiVarCurr);
        else
            allTable{rowNum,startColNum+j}=data;
        end
    end
    
    if isMulti
        allTable{rowNum,multiVarCol}=multiVarNames{i}; % The multi var goes after the metaVarNames.
    end

    for j=1:length(varNames)
        try
            data=loadMAT(dataPath,varNames{j},subName,trialName);
        catch
            data=loadMAT(dataPath,varNames{j},subName);
        end

        if isfield(data,'All')
            data=data.All;
        elseif isfield(data,'Average')
            data=data.Average;
        end

        if ~isempty(multiVarCurr) && isfield(data,multiVarCurr)
            try
                allTable{rowNum,multiVarCol+j}=data.(multiVarCurr)(dims(j));
            catch
                allTable{rowNum,multiVarCol+j}=data.(multiVarCurr);
            end
        elseif isstruct(data) && ~isempty(multiVarCurr) % Missing this field
            allTable{rowNum,multiVarCol+j}=NaN;
        else
            if isnumeric(data)
                try
                    allTable{rowNum,multiVarCol+j}=data(dims(j));                
                catch
                    allTable{rowNum,multiVarCol+j}=data;                
                end
            else
                allTable{rowNum,multiVarCol+j}=data;
            end
        end

        if isnumeric(allTable{rowNum,multiVarCol+j})
            assert(isscalar(allTable{rowNum,multiVarCol+j}));
        end

        assert(~isstruct(allTable{rowNum,multiVarCol+j}));
    end

end

%% Rearrange the stats table so that the repetitions are in blocks, incrementing from left to right (e.g. all trials of one subject clumped together, then all trials of one condition)
disp('Reorder the table so that the repetitions are in blocks');
numCols=2+length(metaVarNames);
if isMulti    
    numCols=numCols+1;
end

for colNum=numCols:-1:2 % Don't sort by the trial name column
    [~,sortIdx]=sort(allTable(:,colNum));
    allTable=allTable(sortIdx,:);
end

%% Add in the trial number now that everything is in the proper order
disp('Add in the trial number now that everything is in the proper order');
trialNumCol=numCols+1;
allTable=[allTable(:,1:trialNumCol-1) cell(size(allTable,1),1) allTable(:,trialNumCol:end)];
uniqueEntries=unique(allTable(:,trialNumCol-1)); % Last meta variable column, or the multi var column
maxEntriesNum=0;

for i=1:length(uniqueEntries)

    entryIdx=ismember(allTable(:,trialNumCol-1),uniqueEntries{i}); % 1 where the current entry is

    entriesDiff=diff([0; entryIdx; 0]); % 1 where the current entry starts, -1 where it ends
    entriesStart=find(entriesDiff==1); % The indices where the current entry starts
    entriesEnd=find(entriesDiff==-1)-1; % -1 to account for the additional zero at the start/end

    assert(isequal(length(entriesStart),length(entriesEnd)));

    for j=1:length(entriesStart)

        if entriesEnd(j)-entriesStart(j)+1>maxEntriesNum
            maxEntriesNum=entriesEnd(j)-entriesStart(j)+1; % The number of repetitions to ensure that every rep block has
        end

        for k=1:entriesEnd(j)-entriesStart(j)+1
            allTable{entriesStart(j)+k-1,trialNumCol}=k; % Add the number
        end

    end

end

%% Ensure that all conditions have the same number of repetitions. Add NaN if it doesn't exist.
disp('Ensure that all conditions have the same number of repetitions');
numericColIdx=[];
for i=1:length(uniqueEntries)

    entryIdx=ismember(allTable(:,trialNumCol-1),uniqueEntries{i}); % 1 where the current entry is

    entriesDiff=diff([0; entryIdx; 0]); % 1 where the current entry starts, -1 where it ends
    entriesStart=find(entriesDiff==1); % The indices where the current entry starts
    entriesEnd=find(entriesDiff==-1)-1; % -1 to account for the additional zero at the start/end

    assert(isequal(length(entriesStart),length(entriesEnd)));

    for j=1:length(entriesStart)

        if entriesEnd(j)-entriesStart(j)+1>maxEntriesNum
            error('Logic error! How are there more entries than the max?');
        end

        if entriesEnd(j)-entriesStart(j)+1==maxEntriesNum
            continue; % If all of the trials are present, skip this set
        end

        % Need to pad the table with entries to ensure that they are all the same length
        numExistReps=entriesEnd(j)-entriesStart(j)+1;
        numRows=maxEntriesNum-numExistReps; % The number of rows to add to the table

        % Determine if repetition & data variables are chars or numeric
        % Repetition variables. Missing entries
        insertData=cell(size(allTable,2),1);

        % Data variables
        for k=trialNumCol+1:size(allTable,2)
            if all(cellfun(@isnumeric,allTable(:,k)))
                insertData{k}=NaN;
                numericColIdx=[numericColIdx; k];
            elseif all([cellfun(@ischar,allTable(:,k)) | cellfun(@isstring,allTable(:,k))])
                insertData{k}='NaN';
                if any(cellfun(@isstring,allTable(:,k)))
                    allTable(:,k)=cellfun(@convertStringsToChars,allTable(:,k),'UniformOutput',false);
                end
            else
                error(['Mixed chars & numeric in table column ' num2str(k)]);
            end
        end

        allTable=[allTable(1:entriesStart(j)+numExistReps-1,:); cell(numRows,size(allTable,2)); allTable(entriesStart(j)+numExistReps:end,:)];

        entriesEnd(j)=entriesEnd(j)+numRows;
        if j<length(entriesStart) % Need to increment the start & end of all the subsequent entries as well.
            entriesStart(j+1:end)=entriesStart(j+1:end)+numRows;
            entriesEnd(j+1:end)=entriesEnd(j+1:end)+numRows;
        end

        allTable(entriesStart(j)+numExistReps:entriesEnd(j),1)={'Missing'}; % Trial is missing.

        % Insert the repetition variables for missing trials.
        allTable(entriesStart(j)+numExistReps:entriesEnd(j),2:trialNumCol-1)=repmat(allTable(entriesStart(j)+numExistReps-1,2:trialNumCol-1),maxEntriesNum-numExistReps,1);

        for k=trialNumCol+1:size(allTable,2)
            allTable(entriesStart(j)+numExistReps:entriesEnd(j),k)=insertData(k); % Data variables
        end

        for k=1:numRows
            allTable{entriesStart(j)+numExistReps+k-1,trialNumCol}=numExistReps+k; % Trial/repetition number
        end

    end

end

numericColIdx=sort(unique(numericColIdx));

%% Organize the table so the subject names match the order in the logsheet
[~,idx,~]=intersect(allTable(:,2),subNames);
idx=[idx; size(allTable,1)+1];

assert(all(diff(diff(idx))==0)); % Check that all subjects have the same number of rows

table2=allTable;
for i=1:length(subNames)
    subName=subNames{i};

    rows=ismember(allTable(:,2),subName);

    numTrials=sum(rows);
    table2((i-1)*numTrials+1:numTrials*i,:)=allTable(rows,:);

end

allTable=table2;