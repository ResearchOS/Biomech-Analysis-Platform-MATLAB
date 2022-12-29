function []=removeProjectButtonPushed(src)

%% PURPOSE: CHANGE A PROJECT'S VISIBILITY TO BE REMOVED FROM THE LIST.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Projects.allProjectsUITree;

projectNode=uiTree.SelectedNodes;

if isempty(projectNode)
    return;
end

classVar=getappdata(fig,'Project');

idx=ismember({classVar.Text},projectNode.Text);

assert(any(idx));

idxNum=find(idx==1);

classVar(idx).Checked=false;

classVar(idx).Visible=false;

setappdata(fig,'Project',classVar);

saveClass(fig,'Project',classVar(idx));

delete(projectNode);

if idxNum>length(uiTree.Children)
    idxNum=idxNum-1;
end

if idxNum==0
    uiTree.SelectedNodes=[];
else
    uiTree.SelectedNodes=uiTree.Children(idxNum);
end

allProjectsUITreeSelectionChanged(fig);