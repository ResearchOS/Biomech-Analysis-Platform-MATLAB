function []=openDataPathButtonPushed(src,event)

%% PURPOSE: OPEN THE SPECIFIED DATA PATH LOCATION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');
project=Current_Project_Name;
fullPath=getClassFilePath(project, 'Project');
struct=loadJSON(fullPath);
computerID=getComputerID();
path=struct.DataPath.(computerID);

if isempty(path) || exist(path,'dir')~=7
    beep;
    warning('Need to enter a valid project path!');
    return;
end

openPathWithDefaultApp(path);