function []=makePubTableNodes(fig,sortIdx,names)

%% PURPOSE: GENERATE THE NODES FOR THE PUBLICATION TABLE UI TREE
handles=getappdata(fig,'handles');

delete(handles.Stats.pubTablesUITree.Children);

if isempty(sortIdx)
%     beep;
%     disp('No results found');
    return;
end

for i=1:length(sortIdx)

    tableNode=uitreenode(handles.Stats.pubTablesUITree,'Text',names{sortIdx(i)});

    if i==1
        handles.Stats.pubTablesUITree.SelectedNodes=tableNode;
    end

end

pubTablesUITreeSelectionChanged(fig);