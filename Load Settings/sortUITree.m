function []=sortUITree(uiTree)

%% PURPOSE: Sort the nodes based on how it was specified.

sortMethod=''; % Get the value from the dropdown
switch sortMethod    
    case 'DateModified (Old->New)'
        dates={uiTree.Children.DateModified};
        [~,idx]=sort(dates,'descending');
    case 'DateModified (New->Old)'
        dates={uiTree.Children.DateModified};
        [~,idx]=sort(dates,'ascending');
    case 'DateCreated (Old->New)'
        dates={uiTree.Children.DateCreated};
        [~,idx]=sort(dates,'descending');
    case 'DateCreated (New->Old)'
        dates={uiTree.Children.DateCreated};
        [~,idx]=sort(dates,'ascending');
    case 'Alphabetical (A->Z)'
        names={uiTree.Children.Text};
        [~,idx]=sort(names,'ascending');
    case 'Alphabetical (Z->A)'
        names={uiTree.Children.Text};
        [~,idx]=sort(names,'decending');
end

uiTree.Children=uiTree.Children(idx);