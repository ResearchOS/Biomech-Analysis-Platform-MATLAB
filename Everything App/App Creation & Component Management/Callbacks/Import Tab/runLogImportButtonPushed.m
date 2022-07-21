function []=runLogImportButtonPushed(src,event)

%% PURPOSE: BRING IN THE DATA FROM THE LOGSHEET TO A MAT VARIABLE
tic;
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct');

macAddress=getComputerID();

logsheetPathMAT=NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT;

numHeaderRows=NonFcnSettingsStruct.Import.NumHeaderRows;
subjIDColHeader=NonFcnSettingsStruct.Import.SubjectIDColHeader;
targetTrialIDColHeader=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;

load(logsheetPathMAT,'logsheetVar');

headerNames=logsheetVar(1,:);
headerVarNames=genvarname(headerNames);

% Get the header names, data types, and trial/subject levels that are checked from the log vars UI tree
checkedNodes=handles.Import.logVarsUITree.CheckedNodes;

useHeaderDataTypes=cell(length(checkedNodes),1);
useHeaderTrialSubject=cell(length(checkedNodes),1);

useHeaderNames={checkedNodes.Text};
useHeaderVarNames=genvarname(useHeaderNames);
useHeadersIdx=ismember(headerNames,useHeaderNames);
useHeadersIdxNums=find(useHeadersIdx==1);

for i=1:length(checkedNodes)

    useHeaderDataTypes{i}=NonFcnSettingsStruct.Import.LogsheetVars.(useHeaderVarNames{i}).DataType;
    useHeaderTrialSubject{i}=NonFcnSettingsStruct.Import.LogsheetVars.(useHeaderVarNames{i}).TrialSubject;

end

trialCheckedVarsIdx=ismember(useHeaderTrialSubject,'Trial');
subjectCheckedVarsIdx=ismember(useHeaderTrialSubject,'Subject');

useHeadersIdxNumsTrial=useHeadersIdxNums(trialCheckedVarsIdx); % Logsheet columns for trial level vars
useHeadersIdxNumsSubject=useHeadersIdxNums(subjectCheckedVarsIdx); % Logsheet columns for subject level vars

useHeaderVarNamesTrial=useHeaderVarNames(trialCheckedVarsIdx);
useHeaderVarNamesSubject=useHeaderVarNames(subjectCheckedVarsIdx);

useHeaderDataTypesTrial=useHeaderDataTypes(trialCheckedVarsIdx);
useHeaderDataTypesSubject=useHeaderDataTypes(subjectCheckedVarsIdx);

subjIDCol=ismember(headerNames,subjIDColHeader);
targetTrialIDCol=ismember(headerNames,targetTrialIDColHeader);

missingSubNameRows=cellfun(@isempty,logsheetVar(:,subjIDCol));

if any(missingSubNameRows)
    disp(['Data not saved! Logsheet missing subject names in the following rows: ' num2str(find(missingSubNameRows'==1))]);
    return;
end

assert(any(subjIDCol));
assert(any(targetTrialIDCol));

% Get the row numbers from the specify trials selected
rowNums=numHeaderRows+1:size(logsheetVar,1); % Temporarily use all rows until specify trials is completed.

dataPath=getappdata(fig,'dataPath');

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

%% Trial level data
if any(trialCheckedVarsIdx) % There is at least one trial level variable
    for rowNum=rowNums

        rowDataTrial=logsheetVar(rowNum,useHeadersIdxNumsTrial);
        subName=logsheetVar{rowNum,subjIDCol};
        trialName=logsheetVar{rowNum,targetTrialIDCol};

        folderName=[dataPath 'MAT Data Files' slash subName slash];

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

            rowDataTrialStruct.(useHeaderVarNamesTrial{varNum})=var;

        end

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
toc;

%% Subject level data
% Need to incorporate specifyTrials here too

subNamesAll=logsheetVar(numHeaderRows+1:end,subjIDCol);
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

            varAll=logsheetVar(currSubRows,useHeadersIdxNumsSubject(varNum));

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

            rowDataSubjectStruct.(useHeaderVarNamesSubject{varNum})=var;

        end

        % Save trial level data
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