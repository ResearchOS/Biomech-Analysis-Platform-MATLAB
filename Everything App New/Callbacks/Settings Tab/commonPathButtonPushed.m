function []=commonPathButtonPushed(src,event)

%% PURPOSE: SET THE COMMON PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=uigetdir(userpath,'Select the common folder path');

if path==0
    return;
end

if exist(path,'dir')~=7
    disp('Specified path is not a directory or does note exist');
    return;
end

handles.Settings.commonPathEditField.Value=path;

commonPathEditFieldValueChanged(fig);