function []=dataPathFieldValueChanged(src)

%% PURPOSE: SET THE DATA PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Projects.dataPathField.Value;

if isempty(path)
    return;
end

project=handles.Projects.allProjectsUITree.SelectedNodes.Text;

fullPath=getClassFilePath(project, 'Project', fig);
projectStruct=loadJSON(fullPath);

if exist(path,'dir')~=7
    disp('Specified path is not a directory or does not exist!');
    return;
end

computerID=getComputerID();

projectStruct.DataPath.(computerID)=path;

saveClass(fig,'Project',projectStruct);