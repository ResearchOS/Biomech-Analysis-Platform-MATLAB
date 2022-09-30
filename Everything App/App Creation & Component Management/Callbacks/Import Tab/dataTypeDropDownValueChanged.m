function []=dataTypeDropDownValueChanged(src,headerName,dataType)

%% PURPOSE:

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

if exist('dataType','var')~=1
    dataType=handles.Import.dataTypeDropDown.Value;
    headerName=handles.Import.logVarsUITree.SelectedNodes.Text;
    runLog=true;
else
    handles.Import.dataTypeDropDown.Value=dataType;
    handles.Import.logVarsUITree.SelectedNodes=findobj(handles.Import.logVarsUITree,'Text',headerName);
    runLog=false;
end

headerNameVar=genvarname(headerName);

% projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

% load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');

NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType=dataType;

setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);
% save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

if runLog
    desc=['Changed data type for logsheet variable ' headerName];
    updateLog(fig,desc,headerName,dataType);
end