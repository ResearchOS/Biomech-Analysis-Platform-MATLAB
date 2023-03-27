function [statsTable,numRepCols,numDataCols,repVars,dataVarNames,numericColIdx]=generateStatsTable(fig,Stats,tableName)

%% PURPOSE: CREATE THE STATS TABLE IN AN EXCEL FILE AND MATLAB MATRIX.
handles=getappdata(fig,'handles');
VariableNamesList=getappdata(fig,'VariableNamesList');

%% Get the names & split codes of the rep vars
isMulti=NaN(length(Stats.Tables.(tableName).RepetitionColumns),1);
for i=1:length(Stats.Tables.(tableName).RepetitionColumns)
    if isfield(Stats.Tables.(tableName).RepetitionColumns(i),'Mult') && ~isempty(Stats.Tables.(tableName).RepetitionColumns(i).Mult)
        isMulti(i)=Stats.Tables.(tableName).RepetitionColumns(i).Mult.PerTrial;
    else
        isMulti(i)=0;
    end
end

% Ensure that the multi variable(s) are all the way at the right side of the repetition vars list.
firstIsMultIdx=find(isMulti==1,1,'first');
isMultiCheck=zeros(length(isMulti),1);
if ~isempty(firstIsMultIdx)
    isMultiCheck(firstIsMultIdx:end)=1;
end
if ~isequal(isMulti,isMultiCheck)
    disp('The multi variables need to be at the bottom of the list (the far right of the table)');
    return;
end

repVars={Stats.Tables.(tableName).RepetitionColumns.Name};
% varNames=cell(size(repVars));
% varCodes=cell(size(repVars));
varNamesInFile=cell(size(repVars));
for i=1:length(repVars)    
    spaceIdx=strfind(repVars{i},' ');
    if isMulti(i)
        assert(isempty(spaceIdx));
        continue; % Because this is a multi-rep var.
    end
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
%     dataVarNames{i}=[dataVars{i} '_' Stats.Tables.(tableName).DataColumns(i).Function];
    dataVarNames{i}=dataVars{i};
end

numDataCols=length(fcnNames);

statsFcnPath=[getappdata(fig,'codePath') 'Statistics'];

oldPath=cd(statsFcnPath);

specifyTrialsName=Stats.Tables.(tableName).SpecifyTrials;
inclStruct=feval(specifyTrialsName);
load(getappdata(fig,'logsheetPathMAT'),'logVar');
allTrialNames=getTrialNames(inclStruct,logVar,fig,0,[]);

%% Set up the multi variable info
cats={};
for i=1:length(Stats.Tables.(tableName).RepetitionColumns)
    if isfield(Stats.Tables.(tableName).RepetitionColumns(i),'Mult') && ~isempty(Stats.Tables.(tableName).RepetitionColumns(i).Mult)
        cats=Stats.Tables.(tableName).RepetitionColumns(i).Mult.Categories;
        break;
    end
end
if isempty(cats)
    cats={''};
    nMulti=1;
else
    nMulti=length(cats); % Number of repetitions (data points) per trial
end

%% Initialize the stats table
subNames=fieldnames(allTrialNames);
numRows=0;
tableTrialNames={};
for sub=1:length(subNames)

    subName=subNames{sub};
    trialFldNames=fieldnames(allTrialNames.(subName));
    for trialNum=1:length(trialFldNames)

        trialName=trialFldNames{trialNum};

        for repNum=allTrialNames.(subName).(trialName)

            for multNum=1:nMulti
                numRows=numRows+1;
                tableTrialNames=[tableTrialNames; trialName];
            end
        end

    end

end

% Plus one for the trial number column between the repetition and data columns. The other plus one is for the trial name all the way to the left.
numCols=length(fcnNames)+length(varNamesInFile)+2;

varNamesInFile=varNamesInFile(~isMulti); % Remove the empty indices for the multi-variables.

statsTable=cell(numRows,numCols);

%% Organize the repetition columns for non-multi variables
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

            % NOTE: NO NEED TO CHECK IF A VARIABLE IS "MULTI" (IN WHICH CASE IT WILL NOT BE FOUND IN THE MAT FILE) BECAUSE THAT IS REMOVED FROM
            % VARNAMESINFILE BEFORE THESE FOR LOOPS

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

            for multNum=1:nMulti
                % Insert the data into proper row & column
                rowNum=rowNum+1;
                for colNum=1:length(var) 
                    statsTable{rowNum,colNum+1}=var{colNum}; % +1 to avoid overwriting the trial name column all the way to the left
                end

                if nMulti>1 % For the repetition variable
                    colNum=colNum+1; % Don't overwrite the non-multi repetition variables
                    statsTable{rowNum,colNum+1}=cats{multNum}; % +1 to avoid overwriting the trial name column all the way to the left
                end

                for i=1:length(varNamesInFile)
                    clearvars(varNamesInFile{i});
                end
            end

        end

    end

end

%% Put data into the data columns
rowNum=0;
minColNum=length(varNamesInFile)+2+sum(isMulti); % +1 for the trial number, the other +1 for the trial name, +sum(isMulti) because I shortened the varNamesInFile to make the above nested for loops work.
setappdata(fig,'tableName',tableName);
multiVarNames={};
for i=1:length(Stats.Tables.(tableName).RepetitionColumns)
    if isMulti(i)
        multiVarNames=Stats.Tables.(tableName).RepetitionColumns(i).Mult.DataVars;
        break;
    end
end
for sub=1:length(subNames)

    subName=subNames{sub};
    trialFldNames=fieldnames(allTrialNames.(subName)); 

    for trialNum=1:length(trialFldNames)

        trialName=trialFldNames{trialNum};

        for repNum=allTrialNames.(subName).(trialName)

            for multNum=1:nMulti
                rowNum=rowNum+1;
                cat=cats{multNum};

                for i=1:length(fcnNames)

                    fcnName=fcnNames{i};
                    setappdata(fig,'fcnName',fcnName);
                    setappdata(fig,'fcnIdx',i);
                    [data]=feval(fcnName,[],subName,trialName,repNum);
                    colNum=minColNum+i;

                    % Check if this is a variable that has been assigned as a "multi" variable.
                    % If so, it should be in a structure format where each field is one category.
                    if ~ismember(dataVarNames{i},multiVarNames)
                        % Assign the same value to multiple rows
                        statsTable{rowNum,colNum}=data;
                        continue;
                    else
                        if isfield(data,cat)
                            statsTable{rowNum,colNum}=data.(cat);
                        else
                            statsTable{rowNum,colNum}=NaN; % This particular trial does not have this particular field.
                            tableTrialNames{rowNum}=[tableTrialNames{rowNum} '_MultiMissing'];
                        end
                    end

                end

            end

        end

    end

end

cd(oldPath);

%% Prepend the trial name column
statsTable(:,1)=tableTrialNames;

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

%% Ensure that all conditions have the same number of repetitions. Add NaN if it doesn't exist.
numericColIdx=[];
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
        % Repetition variables. Missing entries
        insertData=cell(size(statsTable,2),1);

        % Data variables
        for k=trialNumCol+1:size(statsTable,2)
            if all(cellfun(@isnumeric,statsTable(:,k)))
                insertData{k}=NaN;
                numericColIdx=[numericColIdx; k];
            elseif all([cellfun(@ischar,statsTable(:,k)) | cellfun(@isstring,statsTable(:,k))])
                insertData{k}='NaN';
                if any(cellfun(@isstring,statsTable(:,k)))
                    statsTable(:,k)=cellfun(@convertStringsToChars,statsTable(:,k),'UniformOutput',false);
                end
            else
                error(['Mixed chars & numeric in table column ' num2str(k)]);
            end
        end

        statsTable=[statsTable(1:entriesStart(j)+numExistReps-1,:); cell(numRows,size(statsTable,2)); statsTable(entriesStart(j)+numExistReps:end,:)];

        entriesEnd(j)=entriesEnd(j)+numRows;
        if j<length(entriesStart) % Need to increment the start & end of all the subsequent entries as well.
            entriesStart(j+1:end)=entriesStart(j+1:end)+numRows;
            entriesEnd(j+1:end)=entriesEnd(j+1:end)+numRows;
        end

        statsTable(entriesStart(j)+numExistReps:entriesEnd(j),1)={'Missing'}; % Trial is missing.

        % Insert the repetition variables for missing trials.
        statsTable(entriesStart(j)+numExistReps:entriesEnd(j),2:trialNumCol-1)=repmat(statsTable(entriesStart(j)+numExistReps-1,2:trialNumCol-1),maxEntriesNum-numExistReps,1);

        for k=trialNumCol+1:size(statsTable,2)
            statsTable(entriesStart(j)+numExistReps:entriesEnd(j),k)=insertData(k); % Data variables
        end

        for k=1:numRows
            statsTable{entriesStart(j)+numExistReps+k-1,trialNumCol}=numExistReps+k; % Trial/repetition number
        end

    end

end

numericColIdx=sort(unique(numericColIdx));