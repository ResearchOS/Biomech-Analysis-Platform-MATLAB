function []=connectNodesButtonPushed(src,event)

%% PURPOSE: CREATE AN EDGE CONNECTING TWO NODES TOGETHER.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'Digraph');

% Change the windowButtonDownFcn callback to just
% store the first and second points clicked.
setappdata(fig,'connectNodesCoords',[NaN NaN; NaN NaN]); % Initialize the nodes to be NaN.
setappdata(fig,'doNothingOnButtonUp',1);
set(fig,'WindowButtonDownFcn',@(fig,event) connectNodesButtonPushedWindowButtonDown(fig));