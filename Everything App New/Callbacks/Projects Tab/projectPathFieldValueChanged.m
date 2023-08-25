function []=projectPathFieldValueChanged(src)

%% PURPOSE: SET THE PROJECT PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Projects.projectPathField.Value;

if isempty(path)
    return;
end

if exist(path,'dir')~=7
    disp('Specified path is not a directory or does not exist!');
    return;
end

projectUUID = getCurrent('Current_Project_Name');
struct=loadJSON(projectUUID);

computerID=getComputerID();

struct.Project_Path.(computerID)=path;

writeJSON(struct);