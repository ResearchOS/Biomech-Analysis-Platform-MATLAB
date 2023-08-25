function []=openDataPathButtonPushed(src,event)

%% PURPOSE: OPEN THE SPECIFIED DATA PATH LOCATION
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectName = getCurrent('Current_Project_Name');
projectStruct = newComputerProjectPaths(projectName); % Ensure that even if the project isn't "current", it still has a field for this computer.
computerID = getCurrent('Computer_ID');
path = projectStruct.Data_Path.(computerID);

if isempty(path) || exist(path,'dir')~=7
    beep;
    disp('Need to enter a valid data path!');
    return;
end

openPathWithDefaultApp(path);