function []=commonPathEditFieldValueChanged(src,event)

%% PURPOSE: SET THE COMMON PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

field=handles.Settings.commonPathEditField;
commonPath=field.Value;

if isempty(commonPath)
    return;
end

if exist(commonPath,'dir')~=7
    return;
end

rootSettingsFile=getRootSettingsFile();

save(rootSettingsFile,'commonPath','-append');