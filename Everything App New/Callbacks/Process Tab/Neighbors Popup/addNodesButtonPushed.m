function [] = addNodesButtonPushed(src, event)

%% PURPOSE: ADD ADDITIONAL NODES TO THE NEIGHBORS GRAPH.

fig = ancestor(src,'figure','toplevel');
handles = getappdata(fig,'handles');

%% Get the graph

G = refreshDigraph(pgui);