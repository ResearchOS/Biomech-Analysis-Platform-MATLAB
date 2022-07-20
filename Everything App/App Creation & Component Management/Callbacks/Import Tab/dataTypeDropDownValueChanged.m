function []=dataTypeDropDownValueChanged(src,event)

%% PURPOSE: 

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

headerName=handles.Import.logVarsUITree.SelectedNodes.Text;
headerNameVar=genvarname(headerName);

dataType=handles.Import.dataTypeDropDown.Value;

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file

NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType=dataType;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');