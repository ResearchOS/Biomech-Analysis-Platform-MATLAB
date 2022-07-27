function []=createNode(fig,fcnName,prevFcnName,fcnSplitName,prevFcnSplitName,coords)

%% PURPOSE: CREATE A NODE IN THE MAP FIGURE
% Inputs:
% fig: The pgui figure object (graphics object)
% fcnName: The name of the function (char)
% prevFcnName: The name of the function to connect it to (char)
% fcnSplitName: The split name of the new function node (char)
% prevFcnSplitName: The split name of the function to connect it to (char)
% coords: The (x,y) coordinates to place the node at (double)

fig=ancestor(fig,'figure','toplevel');
handles=getappdata(fig,'handles');
axes();

nodeSize=60;
nodeFaceColor='black';
nodeEdgeColor='black';
lineColor='blue';

if isequal(fcnName,'Logsheet') && isequal(prevFcnName,'0') && isequal(fcnSplitName,'Logsheet') && isequal(prevFcnSplitName,'0') ...
        && isequal(coords,[0 0])
    scatter(handles.Process.mapFigure,coords(1),coords(2),nodeSize,'w','MarkerFaceColor',nodeFaceColor,'MarkerEdgeColor',nodeEdgeColor);
    xlim(handles.Process.mapFigure,[-1 5]);
    ylim(handles.Process.mapFigure,[-5 1]);
    return;
end