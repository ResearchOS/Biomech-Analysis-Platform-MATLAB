function []=makeStatsFcnNodes(fig,sortIdx,fcnNames)

%% PURPOSE: CREATE THE NODES FOR THE STATS FUNCTIONS
handles=getappdata(fig,'handles');

delete(handles.Stats.fcnsUITree.Children);

if isempty(sortIdx)
    beep;
    disp('No results found');
    return;
end

for i=1:length(sortIdx)

    fcnNode=uitreenode(handles.Stats.fcnsUITree,'Text',fcnNames{sortIdx(i)});
    fcnNode.ContextMenu=handles.Stats.openStatsFcnContextMenu;

    if i==1
        handles.Stats.fcnNames.SelectedNodes=fcnNode;
    end

end

fcnsUITreeSelectionChanged(fig);