function []=makeCompNodes(fig,sortIdx,names)

%% PURPOSE: CREATE THE COMPONENT NODES
handles=getappdata(fig,'handles');

delete(handles.Plot.allComponentsUITree.Children);

if isempty(sortIdx)
    beep;
    disp('No results found');
    return;
end

for i=1:length(sortIdx)

    compNode=uitreenode(handles.Plot.allComponentsUITree,'Text',names{sortIdx(i)});

    if i==1
        handles.Plot.allComponentsUITree.SelectedNodes=compNode;
    end

end

allComponentsUITreeSelectionChanged(fig);