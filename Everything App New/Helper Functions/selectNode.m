function [selNode]=selectNode(uiTree,text)

%% PURPOSE: SELECT THE NODE WITH THE CORRESPONDING TEXT.

[name,id,psid]=deText(text);
piText=[name '_' id];

children=uiTree.Children;

texts={children.Text};

idx=contains(texts,piText);

if ~any(idx)
    uiTree.SelectedNodes=[];
    return;
end

if isempty(psid)
    selNode=children(idx);
    uiTree.SelectedNodes=selNode;
    return;
end

currNode=children(idx);
childIdx=ismember({currNode.Children.Text},text);

if isempty(childIdx)
    selNode=[];
    uiTree.SelectedNodes=selNode;
    return;
end

selNode=currNode.Children(childIdx);
uiTree.SelectedNodes=selNode;