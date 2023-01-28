function []=removeVariableButtonPushed(src,event)

%% PURPOSE: REMOVE A VARIABLE FROM THE LIST.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.allVariablesUITree;

variableNode=uiTree.SelectedNodes;

if isempty(variableNode)
    return;
end

varPath=getClassFilePath(variableNode.Text, 'Variable');
struct=loadJSON(varPath);

idx=ismember({uiTree.Children.Text},variableNode.Text);

assert(any(idx));

idxNum=find(idx==1);

struct.Checked=false;

struct.Visible=false;

saveClass('Variable',struct);

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