function []=makeCurrCompNodes(fig,currPlot)

%% PURPOSE: CREATE THE NODES FOR THE CURRENT COMPONENTS IN THIS PLOT.
handles=getappdata(fig,'handles');

delete(handles.Plot.currCompUITree.Children);

compNames=fieldnames(currPlot);

if isempty(compNames)
    return;
end

for i=1:length(compNames)

    letters=fieldnames(currPlot.(compNames{i}));

    compNode=uitreenode(handles.Plot.currCompUITree,'Text',compNames{i});

    for j=1:length(letters)

        letNode=uitreenode(compNode,'Text',letters{j});

        if i==1 && j==1
            handles.Plot.currCompUITree.SelectedNodes=letNode;
            expand(compNode);
        end

    end

end