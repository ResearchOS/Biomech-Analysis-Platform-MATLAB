function []=disconnectNodesButtonPushed(src,disconnectNodesCoords)

%% PURPOSE: REMOVE A CONNECTION BETWEEN TWO NODES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('disconnectNodesCoords','var')~=1    
    setappdata(fig,'disconnectNodesCoords',[NaN NaN; NaN NaN]); % Initialize the nodes to be NaN.
    setappdata(fig,'doNothingOnButtonUp',1);
    set(fig,'WindowButtonDownFcn',@(fig,event) disconnectNodesButtonPushedWindowButtonDown(fig));
else
    desc='Clicked button to disconnect one processing split from two function nodes';
    updateLog(fig,desc,disconnectNodesCoords);
    setappdata(fig,'disconnectNodesCoords',[NaN NaN; NaN NaN]); % Initialize the nodes to be NaN.
    setappdata(fig,'doNothingOnButtonUp',1);
    set(fig,'WindowButtonDownFcn',@(fig,event) disconnectNodesButtonPushedWindowButtonDown(fig,disconnectNodesCoords));
end

