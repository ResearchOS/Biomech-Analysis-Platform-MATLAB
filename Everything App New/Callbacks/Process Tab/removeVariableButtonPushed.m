function []=removeVariableButtonPushed(src,event)

%% PURPOSE: REMOVE A VARIABLE FROM THE LIST.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.allVariablesUITree;

variableNode=uiTree.SelectedNodes;

if isempty(variableNode)
    return;
end

classVar=getappdata(fig,'Variable');

idx=ismember({classVar.Text},variableNode.Text);

assert(any(idx));

idxNum=find(idx==1);

classVar(idx).Checked=false;

classVar(idx).Visible=false;

setappdata(fig,'Variable',classVar);

saveClass(fig,'Variable',classVar(idx));

delete(variableNode);

if idxNum>length(uiTree.Children)
    idxNum=idxNum-1;
end

if idxNum==0
    uiTree.SelectedNodes=[];
else
    uiTree.SelectedNodes=uiTree.Children(idxNum);
end

allVariablesUITreeSelectionChanged(fig);