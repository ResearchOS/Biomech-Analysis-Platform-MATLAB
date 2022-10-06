function []=makeTableNodes(fig,sortIdx,names)

%% PURPOSE: CREATE THE STATS TABLES NODES
handles=getappdata(fig,'handles');

delete(handles.Stats.tablesUITree.Children);

if isempty(sortIdx)
    beep;
    disp('No results found');
    return;
end

for i=1:length(sortIdx)

    tableNode=uitreenode(handles.Stats.tablesUITree,'Text',names{sortIdx(i)});

    if i==1
        handles.Stats.tablesUITree.SelectedNodes=tableNode;
    end

end

tablesUITreeSelectionChanged(fig);