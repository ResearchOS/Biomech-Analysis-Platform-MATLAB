function [newTexts]=checkDeps(texts)

%% PURPOSE: CHECK THAT ALL DEPENDENCIES ARE UP TO DATE FOR THE SPECIFIED PROCESS FUNCTIONS

% 1. Be sure to only look at process functions that are within the current
% process group.

projectSettingsFile=getProjectSettingsFile();
Current_ProcessGroup_Name=loadJSON(projectSettingsFile,'Current_ProcessGroup_Name');
processGroup=Current_ProcessGroup_Name;

for i=1:length(texts)

    text=texts{i};

    fullPath=getClassFilePath(text, 'Process');
    processStruct=loadJSON(fullPath);

    % The date that the process function was modified.
    % If after the date that any of the input variables were modified, then
    % add this process function to the list.
    processDateModified=processStruct.DateModified;

    varNames=getVarNamesArray(processStruct,'InputVariables');

    for j=1:length(varNames)

        varName=varNames{j};
        varPath=getClassFilePath(varName,'Variable');
        varStruct=loadJSON(varPath);

        varProcessNames=varStruct.ForwardLinks_Process; % The process structs that use this variable.

    end

end