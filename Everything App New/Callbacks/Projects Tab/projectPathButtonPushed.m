function []=projectPathButtonPushed(src)

%% PURPOSE: OPEN A UI FOLDER PICKER FOR THE DATA PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=uigetdir(userpath,'Select the folder containing the data');

if path==0
    return;
end

if exist(path,'dir')~=7
    disp('Specified path is not a directory or does not exist');
    return;
end

handles.Projects.projectPathField.Value=path;

projectPathFieldValueChanged(fig);