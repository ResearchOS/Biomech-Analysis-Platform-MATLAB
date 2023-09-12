function []=dataPathFieldValueChanged(src)

%% PURPOSE: SET THE DATA PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Projects.dataPathField.Value;

if isempty(path)
    return;
end

if exist(path,'dir')~=7
    disp('Specified path is not a directory or does not exist!');
    return;
end

setCurrent(path, 'Data_Path');

% projectUUID = getCurrent('Current_Project_Name');
% struct=loadJSON(projectUUID);
% 
% computerID=getComputerID();
% 
% struct.Data_Path.(computerID)=path;
% 
% writeJSON(struct);