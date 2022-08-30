function []=disconnectNodesButtonPushed(src,event)

%% PURPOSE: REMOVE A CONNECTION BETWEEN TWO NODES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

setappdata(fig,'disconnectNodesCoords',[NaN NaN; NaN NaN]); % Initialize the nodes to be NaN.
setappdata(fig,'doNothingOnButtonUp',1);
set(fig,'WindowButtonDownFcn',@(fig,event) disconnectNodesButtonPushedWindowButtonDown(fig));
