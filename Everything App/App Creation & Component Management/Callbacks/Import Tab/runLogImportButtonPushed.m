function []=runLogImportButtonPushed(src,event)

%% PURPOSE: BRING IN THE DATA FROM THE LOGSHEET TO A MAT VARIABLE
tic;
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

assignin('base','gui',fig);

% projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

splitName='Default'; % The name of the current processing split
splitCode='001'; % Do logsheet variables ever need to be anything besides '001'?
% splitCode=genSplitCode(projectSettingsMATPath,{''},splitName);

% load(projectSettingsMATPath,'NonFcnSettingsStruct','Digraph');
Digraph=getappdata(fig,'Digraph');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');

macAddress=getComputerID();

logsheetPathMAT=NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT;

numHeaderRows=NonFcnSettingsStruct.Import.NumHeaderRows;
subjIDColHeader=NonFcnSettingsStruct.Import.SubjectIDColHeader;
targetTrialIDColHeader=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;

if numHeaderRows<0
    disp(['Need to enter the number of header rows!']);
    return;
end

load(logsheetPathMAT,'logVar');

headerNames=logVar(1,:);
% headerVarNames=genvarname(headerNames);

% Get the header names, data types, and trial/subject levels that are checked from the log vars UI tree
checkedNodes=handles.Import.logVarsUITree.CheckedNodes;

if isempty(checkedNodes)
    disp('Check a box to import a variable from the logsheet!');
    return;
end

useHeaderDataTypes=cell(length(checkedNodes),1);
useHeaderTrialSubject=cell(length(checkedNodes),1);

useHeaderNames={checkedNodes.Text};
useHeaderVarNames=genvarname(useHeaderNames);
for i=1:length(useHeaderNames)
    useHeadersIdxNums(i)=find(ismember(headerNames,useHeaderNames{i})==1);
end
% useHeadersIdx=ismember(headerNames,useHeaderNames);
% useHeadersIdxNums=find(useHeadersIdx==1);

for i=1:length(checkedNodes)
    useHeaderDataTypes{i}=NonFcnSettingsStruct.Import.LogsheetVars.(useHeaderVarNames{i}).DataType;
    useHeaderTrialSubject{i}=NonFcnSettingsStruct.Import.LogsheetVars.(useHeaderVarNames{i}).TrialSubject;
end

trialCheckedVarsIdx=ismember(useHeaderTrialSubject,'Trial');
subjectCheckedVarsIdx=ismember(useHeaderTrialSubject,'Subject');

useHeadersIdxNumsTrial=useHeadersIdxNums(trialCheckedVarsIdx); % Logsheet columns for trial level vars
useHeadersIdxNumsSubject=useHeadersIdxNums(subjectCheckedVarsIdx); % Logsheet columns for subject level vars

useHeaderVarNamesTrial=useHeaderVarNames(trialCheckedVarsIdx)';
useHeaderVarNamesSubject=useHeaderVarNames(subjectCheckedVarsIdx)';

useHeaderDataTypesTrial=useHeaderDataTypes(trialCheckedVarsIdx);
useHeaderDataTypesSubject=useHeaderDataTypes(subjectCheckedVarsIdx);

subjIDCol=ismember(headerNames,subjIDColHeader);
targetTrialIDCol=ismember(headerNames,targetTrialIDColHeader);

missingSubNameRows=cellfun(@isempty,logVar(:,subjIDCol));

if any(missingSubNameRows)
    disp(['Data not saved! Logsheet missing subject names in the following rows: ' num2str(find(missingSubNameRows'==1))]);
    return;
end

if ~any(subjIDCol)
    disp(['Missing subject codename column header. Expected header name: ' headerNames{subjIDCol}]);
    return;
end

if ~any(targetTrialIDCol)
    disp(['Missing target trial ID column header. Expected header name: ' headerNames{targetTrialIDCol}]);
    return;
end

if exist('projectStruct','var')~=1
    projectStruct=[];
end

% Get the specify trials name
specTrialsName=Digraph.Nodes.SpecifyTrials{1};
if isempty(specTrialsName)
    beep;
    disp('Select the specify trials for the logsheet import!');
    return;
end
oldPath=cd([getappdata(fig,'codePath') 'SpecifyTrials']);
inclStruct=feval(specTrialsName);
allTrialNames=getTrialNames(inclStruct,logVar,fig,0,projectStruct);
% rowNums=(1:size(logVar,1))'; % Initialize the row numbers
rowsIdx=false(size(logVar,1),1);
subNames=fieldnames(allTrialNames);

for i=1:length(subNames)    
    subName=subNames{i};
    trialNames=allTrialNames.(subName);
    trialNames=fieldnames(trialNames);
%     rowsIdxCurrent=false(size(rowsIdx)); % Current subject initialize
    rowsIdxCurrent=ismember(logVar(:,subjIDCol),subName) & ismember(logVar(:,targetTrialIDCol),trialNames);
    rowsIdx(rowsIdxCurrent)=true;

end
cd(oldPath);

% Get the row numbers from the specify trials selected
rowNums=find(rowsIdx==1);
rowNums=rowNums(rowNums>=numHeaderRows+1); % Temporarily use all rows until specify trials is completed.

dataPath=getappdata(fig,'dataPath');

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

%% Trial level data
if any(trialCheckedVarsIdx) % There is at least one trial level variable
    for rowNumIdx=1:length(rowNums)
        rowNum=rowNums(rowNumIdx);

        rowDataTrial=logVar(rowNum,useHeadersIdxNumsTrial);
        subName=logVar{rowNum,subjIDCol};
        trialName=logVar{rowNum,targetTrialIDCol};        

        % Handle trial level data
        for varNum=1:length(rowDataTrial)

            var=rowDataTrial{varNum};

            if isa(var,'cell')
                var=var{1};
            end

            switch useHeaderDataTypesTrial{varNum}
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

            assert(isa(var,useHeaderDataTypesTrial{varNum}));

            rowDataTrialStruct.([useHeaderVarNamesTrial{varNum} '_' splitCode])=var;

        end        

        folderName=[dataPath 'MAT Data Files' slash subName slash];

        % Save trial level data
        if exist(folderName,'dir')~=7
            mkdir(folderName);
        end

        fileName=[folderName trialName '_' subName '_' projectName '.mat'];

        if exist(fileName,'file')~=2
            save(fileName,'-struct','rowDataTrialStruct','-v6','-mat');
        else
            save(fileName,'-struct','rowDataTrialStruct','-append');
        end

    end
end

%% Subject level data
% Need to incorporate specifyTrials here too

subNamesAll=logVar(numHeaderRows+1:end,subjIDCol);
subNames=unique(subNamesAll); % The complete list of subject names

rowNums=cell(length(subNames),1);
for i=1:length(subNames)

    subName=subNames{i};

    rowNums{i}=[zeros(numHeaderRows,1); ismember(subNamesAll,subName)];

end

if any(subjectCheckedVarsIdx)
    for subNum=1:length(subNames)
        currSubRows=logical(rowNums{subNum});

        subName=subNames{subNum};

        folderName=[dataPath 'MAT Data Files' slash subName slash];

        for varNum=1:length(useHeadersIdxNumsSubject)

            varAll=logVar(currSubRows,useHeadersIdxNumsSubject(varNum));

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
                        disp(['Non-unique entries in logsheet for subject ' subName ' variable ' headerNames{useHeadersIdxNumsSubject(varNum)}]);
                        return;
                    end
                end

            end

            if isa(var,'cell')
                var=var{1};
            end

            switch useHeaderDataTypesSubject{varNum}
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

            assert(isa(var,useHeaderDataTypesSubject{varNum}));            

            rowDataSubjectStruct.([useHeaderVarNamesSubject{varNum} '_' splitCode])=var;

        end

        % Save subject level data
        if exist(folderName,'dir')~=7
            mkdir(folderName);
        end

        fileName=[folderName subName '_' projectName '.mat'];               

        if exist(fileName,'file')~=2
            save(fileName,'-struct','rowDataSubjectStruct','-v6','-mat');
        else
            save(fileName,'-struct','rowDataSubjectStruct','-append');
        end

    end
end

% Save the saved variables' metadata to the project settings .mat file
setSavedVarsList_Logsheet(splitName,useHeaderNames);

a=toc;
disp(['Variables successfully imported from logsheet in ' num2str(round(a,2)) ' seconds: ']);

cellDisp(1,:)=useHeaderDataTypes';
cellDisp(2,:)=useHeaderTrialSubject';
disp(cell2table(cellDisp,'VariableNames',useHeaderNames));

if ~getappdata(fig,'isRunLog')
    desc='Imported data from the logsheet.';
    updateLog(fig,desc);
end