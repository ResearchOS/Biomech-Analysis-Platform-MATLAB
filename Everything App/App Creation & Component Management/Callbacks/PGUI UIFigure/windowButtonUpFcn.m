function []=windowButtonUpFcn(src,event)

%% PURPOSE: RECORD WHEN THE MOUSE BUTTON IS CLICKED (UP). ONLY ACTIVATES IF THE CLICK WAS ON THE UIAXES OBJECT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~isequal(handles.Tabs.tabGroup1.SelectedTab.Title,'Process')
    return;
end

doNothing=getappdata(fig,'doNothingOnButtonUp');
if isequal(doNothing,1)
    setappdata(fig,'doNothingOnButtonUp',0);
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

h=findobj(handles.Process.mapFigure,'Type','GraphPlot');

% Remove all current selections, and their visuals
if multi==0
    h.MarkerSize=4;
    h.NodeColor=[0 0.447 0.741];
end

% projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'Digraph');
Digraph=getappdata(fig,'Digraph');

digraphCoords=Digraph.Nodes.Coordinates;

% Select all nodes within the rectangle created by the button up and down
% coordinates
if isClickAndDrag==1
    rect=[currPointDown; currPointUp];
    nodeRows=digraphCoords(:,1)>=min(rect(:,1)) & digraphCoords(:,1)<=max(rect(:,1)) ...
        & digraphCoords(:,2)>=min(rect(:,2)) & digraphCoords(:,2)<=max(rect(:,2));
else
    selTol=0.5;
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
    handles.Process.convertVarHardDynamicButton.Value=false;
    handles.Process.argDescriptionTextArea.Value={''};
    handles.Process.fcnDescriptionTextArea.Value={''};
    handles.Process.argNameInCodeField.Value='';
    return;
end

% Check that all functions are connected first.
nodeRowsNums=find(nodeRows==1);
nodeRowsNums=nodeRowsNums(~ismember(nodeRowsNums,1));
for i=1:length(nodeRowsNums)

    if isequal(nodeRowsNums(i),1)
%         disp('Selected logsheet node!');
%         return;
    end

    if isempty(inedges(Digraph,nodeRowsNums(i))) && isempty(outedges(Digraph,nodeRowsNums(i)))
        disp('Must connect functions before selecting them!');
        disp(['Node at (' num2str(Digraph.Nodes.Coordinates(nodeRowsNums(i),:)) ') Not Connected']);
        return;
    end

end

highlightedFcnsChanged(fig,Digraph); % Update the rest of the Process tab with the selections of the current functions