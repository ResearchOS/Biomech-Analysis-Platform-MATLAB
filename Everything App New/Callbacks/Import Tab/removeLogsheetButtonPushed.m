function []=removeLogsheetButtonPushed(src,event)

%% PURPOSE: REMOVE A LOGSHEET FROM THE LIST

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Import.allLogsheetsUITree;

logsheetNode=uiTree.SelectedNodes;

if isempty(logsheetNode)
    return;
end

logPath=getClassFilePath(logsheetNode.Text,'Logsheet');
logStruct=loadJSON(logPath);

idx=ismember({uiTree.Children.Text},logsheetNode.Text);

assert(any(idx));

idxNum=find(idx==1);

logStruct.Checked=false;

logStruct.Visible=false;

saveClass('Logsheet',logStruct);

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