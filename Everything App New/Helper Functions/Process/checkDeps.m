function [newTexts]=checkDeps(texts)

%% PURPOSE: CHECK THAT ALL DEPENDENCIES ARE UP TO DATE FOR THE SPECIFIED PROCESS FUNCTIONS

for i=1:length(texts)

    text=texts{i};

    fullPath=getClassFilePath(text, 'Process');
    processStruct=loadJSON(fullPath);

    % The date that the process function was modified.
    % If after the date that any of the input variables were modified, then
    % add this process function to the list.
    processDateModified=processStruct.DateModified;

    varNames=getVarNamesArray(processStruct);

end