function [G] = refreshDigraph(src)

%% PURPOSE: HELPER FUNCTION TO REFRESH THE DIGRAPH.

fig=ancestor(src,'figure','toplevel');

containerUUID = getCurrent('Current_Analysis');
list = getUnorderedList(containerUUID);
links = loadLinks(list);
G = linkageToDigraph(links);
setappdata(fig,'digraph',G);