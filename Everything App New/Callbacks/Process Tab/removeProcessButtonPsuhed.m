function []=removeProcessButtonPsuhed(src,event)

%% PURPOSE: REMOVE A PROCESSING FUNCTION FROM THE LIST

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.allProcessUITree;

processNode=uiTree.SelectedNodes;

if isempty(processNode)
    return;
end

classVar=getappdata(fig,'Process');

idx=ismember({classVar.Text},processNode.Text);

assert(any(idx));

idxNum=find(idx==1);

classVar(idx).Checked=false;

classVar(idx).Visible=false;

setappdata(fig,'Process',classVar);

saveClass(fig,'Process',classVar(idx));

delete(processNode);

if idxNum>length(uiTree.Children)
    idxNum=idxNum-1;
end

if idxNum==0
    uiTree.SelectedNodes=[];
else
    uiTree.SelectedNodes=uiTree.Children(idxNum);
end

allProcessUITreeSelectionChanged(fig);