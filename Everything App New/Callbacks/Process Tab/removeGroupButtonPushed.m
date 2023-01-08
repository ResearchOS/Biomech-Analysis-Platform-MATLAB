function []=removeGroupButtonPushed(src,event)

%% PURPOSE: REMOVE A PROCESSING FUNCTION GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.allGroupsUITree;

groupNode=uiTree.SelectedNodes;

if isempty(groupNode)
    return;
end

% classVar=getappdata(fig,'Process');
slash=filesep;
commonPath=getCommonPath(fig);
classFolder=[commonPath slash 'ProcessGroup'];
struct=loadClassVar(fig,classFolder);

idx=ismember(struct.Text,groupNode.Text);

assert(any(idx));

idxNum=find(idx==1);

struct.Checked=false;

struct.Visible=false;

% setappdata(fig,'Process',classVar);

saveClass(fig,'ProcessGroup',struct);

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