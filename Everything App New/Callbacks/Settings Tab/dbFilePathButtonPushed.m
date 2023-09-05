function []=dbFilePathButtonPushed(src,event)

%% PURPOSE: SET THE COMMON PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=uigetdir(userpath,'Select the DB folder');

if path==0
    return;
end

if exist(path,'dir')~=7
    disp('Specified path is not a directory or does not exist');
    return;
end

handles.Settings.dbFilePathEditField.Value=[path filesep 'biomechOS.db'];

dbFilePathEditFieldValueChanged(fig);