function []=logVarsUITreeSelectionChanged(src,event)

%% PURPOSE: SHOW THE ATTRIBUTES OF THE CURRENTLY SELECTED LOGSHEET VARIABLE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

headerName=handles.Import.logVarsUITree.SelectedNodes.Text;
headerNameVar=genvarname(headerName);

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct');

handles.Import.dataTypeDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType;
handles.Import.trialSubjectDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject;
handles.Import.logVarNameField.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).VarName;