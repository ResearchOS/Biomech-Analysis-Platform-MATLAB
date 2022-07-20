function []=subjIDColHeaderFieldValueChanged(src,event)

%% PURPOSE: SET & STORE THE SUBJECT ID COLUMN HEADER IN THE LOGSHEET

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

headerName=handles.Import.subjIDColHeaderField.Value;

if isempty(headerName)
    return;
end

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct');

NonFcnSettingsStruct.Import.SubjectIDColHeader=headerName;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

logsheetPathFieldValueChanged(fig);