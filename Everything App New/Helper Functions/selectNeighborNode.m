function [newNode]=selectNeighborNode(currNode,dir)

%% PURPOSE: SELECT THE NEIGHBORING NODE IN UI TREE. IF NONE, SELECT THE PARENT NODE.

if exist('dir','var')~=1
    dir=1; % Select the next node down (after the current).
    % dir=0; % Select the next node up (before the current).
end

if isequal(dir,'before')
    dir = 0;
end
if isequal(dir,'after')
    dir = 1;
end

uiTree=getUITreeFromNode(currNode);

if isempty(currNode)
    newNode=[];
    uiTree.SelectedNodes=newNode;
    return;
end

parent=currNode.Parent;
children=parent.Children;

if length(children)==1
    newNode=parent;
    if isequal(class(newNode),'matlab.ui.container.CheckBoxTree')
        uiTree.SelectedNodes=[];
    else
        uiTree.SelectedNodes=newNode;
    end
    return;
end

currIdx=find(ismember(children,currNode)==1);

if currIdx==1
    dir=1;
elseif currIdx==length(children)
    dir=0;
end

if dir==0
    newIdx=currIdx-1;
    if newIdx==0
        newIdx=newIdx+1;
    end
elseif dir==1
    newIdx=currIdx+1;
    if newIdx>length(children)
        newIdx=newIdx-1;
    end
end

newNode=children(newIdx);
uiTree.SelectedNodes=newNode;