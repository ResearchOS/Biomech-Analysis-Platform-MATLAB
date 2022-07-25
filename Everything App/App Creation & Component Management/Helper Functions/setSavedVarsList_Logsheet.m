function []=setSavedVarsList_Logsheet(splitName,guiNames)

%% PURPOSE: UPDATE AND SAVE THE LIST OF SAVED VARIABLES TO THE CURRENT PROJECT'S SETTINGS MAT PATH
% NOTE: IN THIS LOGSHEET VERSION OF SETSAVEDVARSLIST, IT ACCEPTS THE NAMES
% OF THE VARS AS SPECIFIED IN THE GUI
% Inputs:
% splitName: The name of the current split to save the variables to (char)
% guiNames: The names of the variables as specified in the GUI (cell array
% of chars)

fig=evalin('base','gui;');
projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

if ismember('VariableNamesList',projectSettingsVarNames)
    load(projectSettingsMATPath,'VariableNamesList');
end

if size(guiNames,1)<size(guiNames,2)
    guiNames=guiNames';
end

guiVarNames=genvarname(guiNames);

if ~iscell(splitName)
    splitName={splitName};
end

splitCode=genSplitCode(projectSettingsMATPath,splitName);

if ~iscell(splitCode)
    splitCode={splitCode};
end

numVars=length(guiNames);

if exist('VariableNamesList','var')~=1 % Initialize the VariableNamesList
    VariableNamesList.GUINames=guiNames;
    VariableNamesList.SaveNames=guiVarNames;
    VariableNamesList.SplitNames=repmat(splitName,numVars,1);
    VariableNamesList.SplitCodes=repmat(splitCode,numVars,1);
    VariableNamesList.Descriptions=repmat({'Enter Arg Description Here'},numVars,1);
    save(projectSettingsMATPath,'VariableNamesList','-append');
    return;
end

% Check if the split already exists. If so, check if those variables
% already exist. Either overwrite, or append to VariableNamesList
% depending

%% Split name does not yet exist
if ~ismember(splitName,VariableNamesList.SplitNames)
    VariableNamesList.GUINames=[VariableNamesList.GUINames; guiNames];
    VariableNamesList.SaveNames=[VariableNamesList.SaveNames; guiVarNames]; % Does not include the split code
    VariableNamesList.SplitNames=[VariableNamesList.SplitNames; repmat(splitName,numVars,1)];
    VariableNamesList.SplitCodes=[VariableNamesList.SplitCodes; repmat(splitCode,numVars,1)];
    VariableNamesList.Descriptions=[VariableNamesList.Descriptions; repmat({'Enter Arg Description Here'},numVars,1)];
    save(projectSettingsMATPath,'VariableNamesList','-append');
    return;
end

%% Split name already exists
% Check if any/all of the variables being saved are part of the
% split already

% Get the idx of the variables not already in the split
currVarsNotInSplit=~(ismember(splitName,VariableNamesList.SplitNames) & ismember(guiNames,VariableNamesList.GUINames));

VariableNamesList.GUINames=[VariableNamesList.GUINames; guiNames(currVarsNotInSplit)];
VariableNamesList.SaveNames=[VariableNamesList.SaveNames; guiVarNames(currVarsNotInSplit)]; % Does not include the split code
VariableNamesList.SplitNames=[VariableNamesList.SplitNames; repmat(splitName,sum(currVarsNotInSplit),1)];
VariableNamesList.SplitCodes=[VariableNamesList.SplitCodes; repmat(splitCode,sum(currVarsNotInSplit),1)];
VariableNamesList.Descriptions=[VariableNamesList.Descriptions; repmat({'Enter Arg Description Here'},numVars,1)];

save(projectSettingsMATPath,'VariableNamesList','-append');