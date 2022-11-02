function []=makePlotNodes(fig,sortIdx,names)

%% PURPOSE: CREATE THE PLOT NODES
handles=getappdata(fig,'handles');

delete(handles.Plot.plotFcnUITree.Children);

if isempty(sortIdx)
    beep;
    disp('No results found');
    return;
end

for i=1:length(sortIdx)

    plotNode=uitreenode(handles.Plot.plotFcnUITree,'Text',names{sortIdx(i)});

    if i==1
        handles.Plot.plotFcnUITree.SelectedNodes=plotNode;
    end

end

plotFcnUITreeSelectionChanged(fig);