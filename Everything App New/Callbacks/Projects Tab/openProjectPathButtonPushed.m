function []=openProjectPathButtonPushed(src,event)

%% PURPOSE: OPEN THE FILE LOCATION FOR THE PROJECT PATH.

% fig=ancestor(src,'figure','toplevel');
% handles=getappdata(fig,'handles');

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');
project=Current_Project_Name;
fullPath=getClassFilePath(project, 'Project');
struct=loadJSON(fullPath);
computerID=getComputerID();
path=struct.ProjectPath.(computerID);

if isempty(path) || exist(path,'dir')~=7
    beep;
    warning('Need to enter a valid project path!');
    return;
end

openPathWithDefaultApp(path);