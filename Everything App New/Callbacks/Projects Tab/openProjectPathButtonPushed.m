function []=openProjectPathButtonPushed(src,event)

%% PURPOSE: OPEN THE FILE LOCATION FOR THE PROJECT PATH.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

name=handles.Projects.projectsLabel.Text;
fullPath=getClassFilePath(name, 'Project', fig);
struct=loadJSON(fullPath);
computerID=getComputerID();
path=struct.ProjectPath.(computerID);

if isempty(path) || exist(path,'dir')~=7
    beep;
    warning('Need to enter a valid project path!');
    return;
end

if ispc==1
    winopen(path);
    return;
end

newPath=['''' path ''''];

system(['open ' newPath]);