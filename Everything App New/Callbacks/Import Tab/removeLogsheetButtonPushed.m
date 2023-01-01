function []=removeLogsheetButtonPushed(src,event)

%% PURPOSE: REMOVE A LOGSHEET FROM THE LIST

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Import.allLogsheetsUITree;

logsheetNode=uiTree.SelectedNodes;

if isempty(logsheetNode)
    return;
end

classVar=getappdata(fig,'Logsheet');

idx=ismember({classVar.Text},logsheetNode.Text);

assert(any(idx));

idxNum=find(idx==1);

classVar(idx).Checked=false;

classVar(idx).Visible=false;

setappdata(fig,'Logsheet',classVar);

saveClass(fig,'Logsheet',classVar(idx));

delete(logsheetNode);

if idxNum>length(uiTree.Children)
    idxNum=idxNum-1;
end

if idxNum==0
    uiTree.SelectedNodes=[];
else
    uiTree.SelectedNodes=uiTree.Children(idxNum);
end

allLogsheetsUITreeSelectionChanged(fig);