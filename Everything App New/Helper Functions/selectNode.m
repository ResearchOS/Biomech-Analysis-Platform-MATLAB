function []=selectNode(uiTree,text)

%% PURPOSE: SELECT THE NODE WITH THE CORRESPONDING TEXT.

children=uiTree.Children;

texts={children.Text};

idx=ismember(texts,text);

if ~any(idx)
    uiTree.SelectedNodes=[];
    return;
end

uiTree.SelectedNodes=children(idx);