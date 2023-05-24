function []=storeSettingsCheckboxValueChanged(src,event)

%% PURPOSE: INDICATE WHETHER TO STORE THE SETTINGS IN GUI APP DATA OR ALWAYS LOAD FROM FILE.
% NOTE: TOGGLING THIS REQUIRES A RESTART.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

rootSettingsFile=getRootSettingsFile();

Store_Settings=handles.Settings.storeSettingsCheckbox.Value;

msg=uiconfirm(fig,'Toggling this requires a restart. Continue?','Confirm Restart');

if ~isequal(msg,'OK')
    handles.Settings.storeSettingsCheckbox.Value=~handles.Settings.storeSettingsCheckbox.Value;
    return;
end

save(rootSettingsFile,'Store_Settings','-append');

close(fig);

oopgui;