function [] =removeFromViewButtonPushed(src,event)

%% PURPOSE: REMOVE SELECTED NODE(S) IN THE DIGRAPH FROM THE VIEW.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

markerSize = getappdata(fig,'markerSize');
remIdx = markerSize==8;

if ~any(remIdx)
    return;
end

Current_View = getCurrent('Current_View');

G = getappdata(fig,'viewG');
remNodes = G.Nodes.Name(remIdx);

removeNodesFromView(fig, remNodes);

G = filterGraph(fig, Current_View);
renderGraph(fig, G);