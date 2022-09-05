function []=archiveDataCheckboxValueChanged(src,event)

%% PURPOSE: INDICATE WHETHER TO ARCHIVE THE DATA ALONG WITH THE CODE FOR THE CURRENT PROJECT.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

value=handles.Projects.archiveDataCheckbox.Value;

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'NonFcnSettingsStruct');

NonFcnSettingsStruct.Projects.ArchiveData=value;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');