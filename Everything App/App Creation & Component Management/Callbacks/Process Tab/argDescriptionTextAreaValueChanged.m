function []=argDescriptionTextAreaValueChanged(src,event)

%% PURPOSE: STORE THE MODIFIED DESCRIPTION TO THE APPROPRIATE VARIABLE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
description=handles.Process.argDescriptionTextArea.Value;

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

if ~ismember('VariableNamesList',projectSettingsVarNames)
    disp(['No variables present yet!']);
    return;
end

load(projectSettingsMATPath,'VariableNamesList');

varGUIName=handles.Process.varsListbox.Value;
% splitName=handles.Process.splitsUITree.SelectedNodes.Text;

%% Find the row of the VariableNamesList pertaining to the current variable and split name. Then, change its description.
% varIdx=ismember(VariableNamesList.GUINames,varGUIName) & ismember(VariableNamesList.SplitNames,splitName);
varIdx=ismember(VariableNamesList.GUINames,varGUIName); % & ismember(VariableNamesList.SplitNames,splitName);

assert(sum(varIdx)==1); % Ensure that it is unique

VariableNamesList.Descriptions{varIdx}=description;

save(projectSettingsMATPath,'VariableNamesList','-append');