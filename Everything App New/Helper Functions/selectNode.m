function []=selectNode(uiTree,text)

%% PURPOSE: SELECT THE NODE WITH THE CORRESPONDING TEXT.

texts={uiTree.Children.Text};

idx=ismember(texts,text);

if ~any(idx)
    uiTree.SelectedNodes=[];
    return;
end

uiTree.SelectedNodes=uiTree.Children(idx);