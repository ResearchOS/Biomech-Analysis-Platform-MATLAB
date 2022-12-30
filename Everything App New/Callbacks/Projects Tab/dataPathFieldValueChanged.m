function []=dataPathFieldValueChanged(src)

%% PURPOSE: SET THE DATA PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Projects.dataPathField.Value;

if isempty(path)
    return;
end

project=handles.Projects.allProjectsUITree.SelectedNodes.Text;

classVar=getappdata(fig,'Project');
idx=ismember({classVar.Text},project);

if exist(path,'dir')~=7
    disp('Specified path is not a directory or does not exist!');
    return;
end

computerID=getComputerID();

classVar(idx).DataPath.(computerID)=path;

setappdata(fig,'Project',classVar);

saveClass(fig,'Project',classVar(idx));