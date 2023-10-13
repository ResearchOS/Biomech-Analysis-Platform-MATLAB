function []=allProjectsUITreeCheckedNodesChanged(src)

%% PURPOSE: (UN)CHECK THE NODES FOR PROJECTS, INDICATING THAT THOSE PROJECTS' SETTINGS SHOULD BE VISIBLE THROUGHOUT THE GUI
% This implementation relies on the fact that as of R2021b, (un)checking
% boxes also selects that node.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Projects.allProjectsUITree;

selNode=uiTree.SelectedNodes;

projectText=selNode.Text;

fullPath=getClassFilePath(projectText,'Project');
projectStruct=loadJSON(fullPath);

saveObj(projectStruct);