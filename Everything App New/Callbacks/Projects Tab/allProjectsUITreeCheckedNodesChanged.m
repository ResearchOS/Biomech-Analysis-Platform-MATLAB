function []=allProjectsUITreeCheckedNodesChanged(src)

%% PURPOSE: (UN)CHECK THE NODES FOR PROJECTS, INDICATING THAT THOSE PROJECTS' SETTINGS SHOULD BE VISIBLE THROUGHOUT THE GUI
% This implementation relies on the fact that as of R2021b, (un)checking
% boxes also selects that node.

% NOTE: THIS MEANS THAT WHEN (UN)CHECKING PROJECTS OTHER THAN THE CURRENT
% ONE, NEED TO GO BACK AND SELECT THE CURRENT PROJECT BEFORE DOING OTHER
% THINGS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Projects.allProjectsUITree;

selNode=uiTree.SelectedNodes;

classVar=getappdata(fig,'Project');
classTexts={classVar.Text};

idx=ismember(classTexts,selNode.Text);

classVar(idx).Checked=~classVar(idx).Checked;

setappdata(fig,'Project',classVar);

saveClass(fig,'Project',classVar(idx));