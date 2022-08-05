function []=windowButtonUpFcn(src,event)

%% PURPOSE: RECORD WHEN THE MOUSE BUTTON IS CLICKED (DOWN). ONLY ACTIVATES IF THE CLICK WAS ON THE UIAXES OBJECT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~isequal(handles.Tabs.tabGroup1.SelectedTab.Title,'Process')
    return;
end

xlims=handles.Process.mapFigure.XLim;
ylims=handles.Process.mapFigure.YLim;

currPointUp=handles.Process.mapFigure.CurrentPoint;

% assert(isequal(currPointUp(1,:),[currPointUp(2,1:2) -1*currPointUp(2,3)]));

currPointUp=currPointUp(1,1:2);

if currPointUp(1)<xlims(1) || currPointUp(1)>xlims(2) || currPointUp(2)<ylims(1) || currPointUp(2)>ylims(2)
    return; % Clicked outside of the axes bounds
end

setappdata(fig,'currentPointUp',currPointUp);
currPointDown=getappdata(fig,'currentPointDown');

% Check if the points up and down are close enough to one another that the
% intended behavior was likely a single click
clickAndDragTol=0.05;
if sqrt((currPointUp(1)-currPointDown(1))^2+(currPointUp(2)-currPointDown(2))^2)<clickAndDragTol
    isClickAndDrag=0;
else
    isClickAndDrag=1;
end

% Get modifier key, if any
if ~isequal(fig.SelectionType,'normal')
    multi=1; % Allow for multiple selections
else
    multi=0; % Only the current selections
end

h=handles.Process.mapFigure.Children;

% Remove all current selections, and their visuals
if multi==0
    h.MarkerSize=4;
    h.NodeColor=[0 0.447 0.741];
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');

digraphCoords=Digraph.Nodes.Coordinates;

% Select all nodes within the rectangle created by the button up and down
% coordinates
if isClickAndDrag==1
    rect=[currPointDown; currPointUp];
    nodeRows=digraphCoords(:,1)>=min(rect(:,1)) & digraphCoords(:,1)<=max(rect(:,1)) ...
        & digraphCoords(:,2)>=min(rect(:,2)) & digraphCoords(:,2)<=max(rect(:,2));
else
    selTol=0.1;
    pos=currPointDown;
    allDigraphDists=sqrt((digraphCoords(:,1)-repmat(pos(1,1),size(digraphCoords,1),1)).^2+(digraphCoords(:,2)-repmat(pos(1,2),size(digraphCoords,1),1)).^2);
    nodeRows=allDigraphDists<selTol;
end

nodeIDs=Digraph.Nodes.NodeNumber(nodeRows);
setappdata(fig,'selectedNodeNumbers',nodeIDs);

if ~any(nodeRows)
    nodeSizes=4;
    h.MarkerSize=nodeSizes;
    nodeColors=[0 0.447 0.741];
    h.NodeColor=nodeColors;
    highlightedFcnsChanged(src,Digraph)
    handles.Process.markImportFcnCheckbox.Value=false;
    return;
end

% Visually highlight all selected nodes
nodeSizes=h.MarkerSize;
if isequal(size(nodeSizes),[1 1])
    nodeSizes=repmat(nodeSizes,length(nodeRows),1);
end

nodeSizes(nodeRows)=8;
h.MarkerSize=nodeSizes;

nodeColors=h.NodeColor;
if isequal(size(nodeColors,1),1)
    nodeColors=repmat(nodeColors,length(nodeRows),1);
end
nodeColors(nodeRows,:)=repmat([0 0 0],sum(nodeRows),1);
h.NodeColor=nodeColors;

highlightedFcnsChanged(fig,Digraph); % Update the rest of the Process tab with the selections of the current functions