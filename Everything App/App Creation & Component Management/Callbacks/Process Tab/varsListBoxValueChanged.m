function []=varsListBoxValueChanged(src,event)

%% PURPOSE: CHANGE GUI DISPLAYS BASED ON WHICH VARIABLE IS SELECTED IN THE LIST.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
% projectName=getappdata(fig,'projectName');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

assert(ismember('VariableNamesList',projectSettingsVarNames));

% load(projectSettingsMATPath,'VariableNamesList');
VariableNamesList=getappdata(fig,'VariableNamesList');

text=handles.Process.varsListbox.SelectedNodes.Text;
spaceIdx=strfind(text,' ');
splitName=text(1:spaceIdx-1);
splitCode=text(spaceIdx+2:end-1);

varName=handles.Process.varsListbox.SelectedNodes.Parent.Text;

% varRowDesc=ismember(VariableNamesList.GUINames,varName) & ismember(VariableNamesList.SplitNames,splitName);
varRow=ismember(VariableNamesList.GUINames,varName); % & ismember(VariableNamesList.SplitNames,splitName);

if isempty(varRow)
    return;
end

handles.Process.argDescriptionTextArea.Value=VariableNamesList.Descriptions{varRow};

defaultName=VariableNamesList.SaveNames{varRow};

handles.Process.argNameInCodeField.Value=defaultName;

handles.Process.convertVarHardDynamicButton.Value=VariableNamesList.IsHardCoded{varRow};