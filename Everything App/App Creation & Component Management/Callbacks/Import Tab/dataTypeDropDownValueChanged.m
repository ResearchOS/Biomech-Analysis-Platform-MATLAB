function []=dataTypeDropDownValueChanged(src,dataType)

%% PURPOSE:

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

headerName=handles.Import.logVarsUITree.SelectedNodes.Text;
headerNameVar=genvarname(headerName);

if exist('dataType','var')~=1
    dataType=handles.Import.dataTypeDropDown.Value;
    runLog=true;
else
    handles.Import.dataTypeDropDown.Value=dataType;
    runLog=false;
end

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file

NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType=dataType;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

if runLog
    desc=['Changed data type for logsheet variable ' headerName];
    updateLog(fig,desc,headerName);
end