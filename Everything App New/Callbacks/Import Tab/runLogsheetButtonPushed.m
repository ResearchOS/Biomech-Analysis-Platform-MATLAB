function []=runLogsheetButtonPushed(src,event)

%% PURPOSE: RUN THE LOGSHEET

tic;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

selNode=handles.Import.allLogsheetsUITree.SelectedNodes;

fullPath=getClassFilePath(selNode);
logsheetStruct=loadJSON(fullPath);

numHeaderRows=logsheetStruct.NumHeaderRows;
subjIDColHeader=logsheetStruct.SubjectCodenameHeader;
targetTrialIDColHeader=logsheetStruct.TargetTrialIDHeader;

computerID=getComputerID();

path=logsheetStruct.LogsheetPath.(computerID);

[folder,file,ext]=fileparts(path);

pathMAT=[folder slash file '.mat'];

checkedIdx=ismember(handles.Import.headersUITree.Children,handles.Import.headersUITree.CheckedNodes);

if ~any(checkedIdx)
    disp('No variables selected!');
    return;
end

load(pathMAT,'logVar');

headers=logsheetStruct.Headers;
levels=logsheetStruct.Level;
types=logsheetStruct.Type;
varNames=logsheetStruct.Variables;

trialIdx=ismember(levels,'Trial') & checkedIdx; % The trial level variables idx that were checked.
subjectIdx=ismember(levels,'Subject') & checkedIdx; % The subject level variables idx that were checked.

subjIDCol=ismember(headers,subjIDColHeader);
targetTrialIDCol=ismember(headers,targetTrialIDColHeader);

specTrialsName=logsheetStruct.SpecifyTrials;
if isempty(specTrialsName)
    beep;
    disp('Need to select specify trials for the logsheet import!');
    return;
end

projectNode=handles.Projects.allProjectsUITree.SelectedNodes;
if isempty(projectNode)
    disp('Select a project first!');
    return;
end

fullPath=getClassFilePath(projectNode);
projectStruct=loadJSON(fullPath);
% projectPath=projectStruct.ProjectPath.(computerID);

% oldPath=cd([projectPath slash 'SpecifyTrials']);
inclStruct=getInclStruct(fig,specTrialsName);
allTrialNames=getTrialNames(inclStruct,logVar,fig,0,logsheetStruct);
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
% cd(oldPath);

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

dataPath=projectStruct.DataPath.(computerID);

if exist(dataPath,'dir')~=7
    disp('Invalid data path!');
    return;
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
            varName=varNames{headerIdxNum}; % The name of the variable struct.

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

            % Save trial-level data.
            % 1. Create a project-independent and project-specific variable struct for this variable if it does not
            % already exist.
            if isempty(varName)
                varStruct=createVariableStruct(fig, headers{headerIdxNum});
                varStruct_PS=createVariableStruct_PS(fig,varStruct);
                varName=varStruct_PS.Text;
                logsheetStruct.Variables{headerIdxNum}=varName;
                saveClass(fig, 'Logsheet', logsheetStruct);
                varNames{headerIdxNum}=varName; % For the next iteration
            end

            % 2. Save data and metadata to file.
            desc=['Logsheet variable (header: ' headers{headerIdxNum} ')'];
            saveMAT(dataPath, desc, varName, var, subName, trialName);

        end

    end
end

toc;

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
            varName=varNames{headerIdxNum}; % The name of the variable struct.

            count=0;
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

            % Save trial-level data.
            % 1. Create a project-independent and project-specific variable struct for this variable if it does not
            % already exist.
            if isempty(varName)
                varStruct=createVariableStruct(fig, headers{headerIdxNum});
                varStruct_PS=createVariableStruct_PS(fig,varStruct);
                varStruct_PS.Level='S';
                saveClass_PS(fig, 'Variable', varStruct_PS);
                varName=varStruct_PS.Text;
                logsheetStruct.Variables{headerIdxNum}=varName;                
                saveClass(fig, 'Logsheet', logsheetStruct);
                varNames{headerIdxNum}=varName; % For the next iteration
            end

            % 2. Save data and metadata to file.
            desc=['Logsheet variable (header: ' headers{headerIdxNum} ')'];
            saveMAT(dataPath, desc, varName, var, subName);

        end

    end
end

toc;