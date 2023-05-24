function []=commonPathEditFieldValueChanged(src,event)

%% PURPOSE: SET THE COMMON PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

field=handles.Settings.commonPathEditField;
commonPath=field.Value;

if isempty(commonPath)
    return;
end

setCommonPath(commonPath);

%% Tell the user that the app should be reloaded, and offer to do it for them.
opt = questdlg('Changing the common folder path requires the app to restart. Do you want to do that now?');

if ~isequal(opt,'Yes')
    return;
end

disp('Closing app window');
close(fig);
disp('Opening new app window');
oopgui;