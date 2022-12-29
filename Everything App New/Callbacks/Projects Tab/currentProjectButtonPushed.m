function []=currentProjectButtonPushed(src)

%% PURPOSE: SELECT THE CURRENT PROJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Projects.allProjectsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

handles.Projects.projectsLabel.Text=selNode.Text;