function []=openProjectPathButtonPushed(src,event)

%% PURPOSE: OPEN THE FILE LOCATION FOR THE PROJECT PATH.

% fig=ancestor(src,'figure','toplevel');
% handles=getappdata(fig,'handles');

projectName = getCurrent('Current_Project_Name');
projectStruct = newComputerProjectPaths(projectName);
computerID = getCurrent('Computer_ID');
path = projectStruct.Project_Path.(computerID);

if isempty(path) || exist(path,'dir')~=7
    beep;
    disp('Need to enter a valid project path!');
    return;
end

openPathWithDefaultApp(path);