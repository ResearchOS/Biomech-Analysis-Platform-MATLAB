function []=setSavedVarsList(projectName,splitName)

%% PURPOSE: UPDATE AND SAVE THE LIST OF SAVED VARIABLES TO THE CURRENT PROJECT'S SETTINGS MAT PATH
% Inputs:
% projectName: Name of the current project (char)
% splitName: The name of the current split to save the variables to
% guiNames: The names of the variables as specified in the GUI

if exist('VariableNamesList','var')~=1 % Initialize the VariableNamesList
    splitNum='001';
    VariableNamesList.GUINames=useHeaderNames;
    VariableNamesList.SaveNames=useHeaderVarNames;
    VariableNamesList.SplitNames=repmat({splitName},numVars,1);
    VariableNamesList.SplitCodes=repmat(splitNum,numVars,1);
    VariableNamesList.Descriptions=repmat({''},numVars,1);
else
    % Check if the split already exists. If so, check if those variables
    % already exist. Either overwrite, or append to VariableNamesList
    % depending

    if ~ismember(splitName,VariableNamesList.SplitNames) % Split name does not yet exist
        % Get the number of splits
        numSplits=max(VariableNamesList.SplitCodes);
        splitNum=numSplits+1;
        switch splitNum
            case splitNum>=100
                splitNum=num2str(splitNum);
            case splitNum>=10
                splitNum=['0' num2str(splitNum)];
            otherwise
                splitNum=['00' num2str(splitNum)];
        end

        VariableNamesList.GUINames=[VariableNamesList.GUINames; useHeaderNames];
        VariableNamesList.SaveNames=[VariableNamesList.SaveNames; useHeaderVarNames];
        VariableNamesList.SplitNames=[VariableNamesList.Splits; repmat(splitName,numVars,1)];
        VariableNamesList.SplitCodes=repmat(splitNum,numVars,1);
        VariableNamesList.Descriptions=[VariableNamesList.Descriptions; repmat({''},numVars,1)];

    else % Split name already exists
        % Check if any/all of the variables being saved are part of the
        % split already



    end
end