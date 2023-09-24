function []=runLogsheetButtonPushed(src,event)

%% PURPOSE: RUN THE LOGSHEET

global conn;

tic;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

disp('Importing metadata from logsheet!');

slash=filesep;

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

logsheetStruct=loadJSON(uuid);

numHeaderRows=logsheetStruct.Num_Header_Rows;
subjIDColHeader=logsheetStruct.Subject_Codename_Header;
targetTrialIDColHeader=logsheetStruct.Target_TrialID_Header;

computerID = getCurrent('Computer_ID');

path=logsheetStruct.Logsheet_Path.(computerID);

[folder,file,ext]=fileparts(path);

pathMAT=[folder slash file '.mat'];

checkedIdx=ismember(handles.Import.headersUITree.Children,handles.Import.headersUITree.CheckedNodes);

if ~any(checkedIdx)
    disp('No variables selected!');
    return;
end

load(pathMAT,'logVar');

params = logsheetStruct.LogsheetVar_Params;
headers={params.Headers}';
levels={params.Level}';
types={params.Type}';
varUUIDs={params.Var_ID}';

trialIdx=ismember(levels,'Trial') & checkedIdx; % The trial level variables idx that were checked.
subjectIdx=ismember(levels,'Subject') & checkedIdx; % The subject level variables idx that were checked.

subjIDCol=ismember(headers,subjIDColHeader);
targetTrialIDCol=ismember(headers,targetTrialIDColHeader);

specTrialsName = getST(uuid);
if isempty(specTrialsName)
    beep;
    disp('Need to select specify trials for the logsheet import!');
    return;
end

dataPath=getCurrent('Data_Path');

if exist(dataPath,'dir')~=7
    disp('Invalid data path!');
    return;
end

inclStruct=getInclStruct(specTrialsName);
allTrialNames=getTrialNames(inclStruct,logVar,0,logsheetStruct);
rowsIdx=false(size(logVar,1),1);
subNames=fieldnames(allTrialNames);

%% Apply specify trials
for i=1:length(subNames)
    subName=subNames{i};
    trialNames=allTrialNames.(subName);
    trialNames=fieldnames(trialNames);
    rowsIdxCurrent=ismember(logVar(:,subjIDCol),subName) & ismember(logVar(:,targetTrialIDCol),trialNames);
    rowsIdx(rowsIdxCurrent)=true;
end

% Get the row numbers from the specify trials selected
rowNums=find(rowsIdx==1);
rowNums=rowNums(rowNums>=numHeaderRows+1); % Specify trials has already been applied

%% Remove rep numbers that are not desired (from desired trials)
rowNumsReps=[];
count=0;
for i=1:length(rowNums) % Iterate over each row to decide at the repetition level if it should be included.
    subName=logVar{rowNums(i),subjIDCol};
    trialName=logVar{rowNums(i),targetTrialIDCol};
    if i==1
        repNum=1;
        if allTrialNames.(subName).(trialName)==1
            trialNamePrev=trialName;
            count=count+1;
            rowNumsReps(count)=rowNums(i);
            continue;
        end
    end

    if isequal(trialNamePrev,trialName)
        repNum=repNum+1;
    else
        repNum=1;
    end

    if allTrialNames.(subName).(trialName)==repNum
        count=count+1;
        rowNumsReps(count,1)=rowNums(i);
    end

    trialNamePrev=trialName;

end

% In case a new variable is created, this helps fill the UI tree
searchTerm=getSearchTerm(handles.Process.variablesSearchField);
sortDropDown=handles.Process.sortVariablesDropDown;

%% Create the variables settings JSON files for subject & trial levels
% date=datetime('now');
selHeaders={handles.Import.headersUITree.CheckedNodes.Text};
sqlquery = ['SELECT LG_ID, VR_ID FROM VR_LG WHERE LG_ID = ''' logsheetStruct.UUID ''';'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
if isempty(fieldnames(t))
    t.VR_ID = {};
else
    if ~iscell(t.VR_ID)
        t.VR_ID = {t.VR_ID};
    end
end
doWrite = false;
for i=1:length(selHeaders)
    idx=ismember(headers,selHeaders{i});
    varUUID=varUUIDs{idx};
    header=headers{idx};
    
    if ~isempty(varUUID) && ismember(varUUID,t.VR_ID)
        continue; % If the variable already exists and is linked to the logsheet don't do anything.
    end

    doWrite = true;
    if isempty(varUUID) % The variable exists but is not linked to the logsheet.
        varStruct = createNewObject(true, 'Variable', header, '', '', true);
        varUUID = varStruct.UUID;
    end
    sqlquery = ['INSERT INTO VR_LG (LG_ID, VR_ID, HeaderName) VALUES (''' logsheetStruct.UUID ''', ''' varUUID ''', ''' header ''');'];
    execute(conn, sqlquery);

    logsheetStruct.LogsheetVar_Params(idx).Var_ID=varUUID;
    varUUIDs{idx}=varUUID; % For the next iteration

end

if doWrite
    writeJSON(logsheetStruct);
    fillUITree(fig, 'Variable', handles.Process.allVariablesUITree, searchTerm, sortDropDown);
end

%% Trial level data
trialIdxNums=find(trialIdx==1);
if any(trialIdx) % There is at least one trial level variable
    for rowNumIdx=1:length(rowNumsReps)
        rowNum=rowNumsReps(rowNumIdx);

        rowDataTrial=logVar(rowNum,trialIdxNums);
        subName=logVar{rowNum,subjIDCol};
        trialName=logVar{rowNum,targetTrialIDCol};

        disp(['Trial Row ' num2str(rowNum)]);

        % Handle trial level data
        for varNum=1:length(rowDataTrial)

            headerIdxNum=trialIdxNums(varNum); % The column index.
            type=lower(types{headerIdxNum});                      
            varUUID=varUUIDs{headerIdxNum}; % The name of the variable struct.

            var=rowDataTrial{varNum};

            if isa(var,'cell')
                var=var{1};
            end

            switch type
                case 'char'
                    if isa(var,'double')
                        if isnan(var)
                            var='';
                        else
                            var=num2str(var);
                        end
                    end
                case 'double'
                    if isa(var,'char')
                        var=str2double(var);
                    end
            end

            assert(isa(var,type));

            % 2. Save data and metadata to file.
            desc=['Logsheet variable (header: ' headers{headerIdxNum} ')'];
            saveMAT(dataPath, desc, varUUID, var, subName, trialName);

            % Update the last modified date, but only for the last row so this doesn't take too much
            % time.
            if rowNumIdx==length(rowNumsReps)
                modifyVarsDate(varUUID);
            end

        end

    end
end

%% Subject level data
% Need to incorporate specifyTrials here too

subNamesAll=logVar(numHeaderRows+1:end,subjIDCol);
subNames=unique(subNamesAll,'stable'); % The complete list of subject names

rowNums=cell(length(subNames),1);
for i=1:length(subNames)

    subName=subNames{i};

    rowNums{i}=[zeros(numHeaderRows,1); ismember(subNamesAll,subName)];

end

subjectIdxNums=find(subjectIdx==1);
if any(subjectIdx)
    for subNum=1:length(subNames)
        currSubRows=logical(rowNums{subNum}) & rowsIdx;

        subName=subNames{subNum};

        disp(['Subject ' subName]);

        for varNum=1:length(subjectIdxNums)

            varAll=logVar(currSubRows,subjectIdxNums(varNum));

            headerIdxNum=subjectIdxNums(varNum); % The column index.
            type=lower(types{headerIdxNum});
            varUUID=varUUIDs{headerIdxNum}; % The name of the variable struct.

            count=0;
            var='';
            for i=1:length(varAll)

                if any(isnan(varAll{i})) || isempty(varAll{i})
                    continue;
                end

                count=count+1;
                if count==1
                    var=varAll{i};
                else
                    if ~isequal(var,varAll{i})
                        disp(['Non-unique entries in logsheet for subject ' subName ' variable ' headers{headerIdxNum}]);
                        return;
                    end
                end

            end

            if isa(var,'cell')
                var=var{1};
            end            

            switch type
                case 'char'
                    if isa(var,'double')
                        if isnan(var)
                            var='';
                        else
                            var=num2str(var);
                        end
                    end
                case 'double'
                    if isa(var,'char')
                        var=str2double(var);
                    end
            end

            assert(isa(var,type));

            % 2. Save data and metadata to file.
            desc=['Logsheet variable (header: ' headers{headerIdxNum} ')'];
            saveMAT(dataPath, desc, varUUID, var, subName);

            modifyVarsDate(varUUID);

        end

    end
end

% This does not work for VR's from LG yet. No need at the moment
setObjsOutOfDate(fig, uuid, false, false);

toc;