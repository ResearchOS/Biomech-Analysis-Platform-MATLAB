function []=sortUITree(uiTree,sortMethod)

%% PURPOSE: Sort the nodes based on how it was specified.

% sortMethod=''; % Get the value from the dropdown
switch sortMethod    
    case 'DateModified (Old->New)'
        data={uiTree.Children.DateModified};
        dir='descend';        
    case 'DateModified (New->Old)'
        data={uiTree.Children.DateModified};
        dir='ascend';
    case 'DateCreated (Old->New)'
        data={uiTree.Children.DateCreated};
        dir='descend';  
    case 'DateCreated (New->Old)'
        data={uiTree.Children.DateCreated};
        dir='ascend';
    case 'Alphabetical (A->Z)'
        data={uiTree.Children.Text};
        dir='ascend';
    case 'Alphabetical (Z->A)'
        data={uiTree.Children.Text};
        dir='descend';  
end

[~,idx]=sort(data,dir);
uiTree.Children=uiTree.Children(idx);