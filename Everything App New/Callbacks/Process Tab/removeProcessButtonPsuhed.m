function []=removeProcessButtonPsuhed(src,event)

%% PURPOSE: REMOVE A PROCESSING FUNCTION FROM THE LIST

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.allProcessUITree;

processNode=uiTree.SelectedNodes;

if isempty(processNode)
    return;
end

processPath=getClassFilePath(processNode.Text,'Process');
processStruct=loadJSON(processPath);

idx=ismember({uiTree.Children.Text},processNode.Text);

assert(any(idx));

idxNum=find(idx==1);

processStruct.Checked=false;

processStruct.Visible=false;

saveClass('Process',processStruct);

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