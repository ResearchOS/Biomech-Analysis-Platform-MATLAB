function []=removeGroupButtonPushed(src,event)

%% PURPOSE: REMOVE A PROCESSING FUNCTION GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.allGroupsUITree;

groupNode=uiTree.SelectedNodes;

if isempty(groupNode)
    return;
end

slash=filesep;
commonPath=getCommonPath();
classFolder=[commonPath slash 'ProcessGroup'];
struct=loadClassVar(classFolder);

idx=ismember(struct.Text,groupNode.Text);

assert(any(idx));

idxNum=find(idx==1);

struct.Checked=false;

struct.Visible=false;

saveClass('ProcessGroup',struct);

delete(groupNode);

if idxNum>length(uiTree.Children)
    idxNum=idxNum-1;
end

if idxNum==0
    uiTree.SelectedNodes=[];
else
    uiTree.SelectedNodes=uiTree.Children(idxNum);
end

allGroupsUITreeSelectionChanged(fig);