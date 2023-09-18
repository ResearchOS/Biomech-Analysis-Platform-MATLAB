function [G] = refreshDigraph(src)

%% PURPOSE: HELPER FUNCTION TO REFRESH THE DIGRAPH.

if nargin==1
    fig=ancestor(src,'figure','toplevel');
end

containerUUID = getCurrent('Current_Analysis');
list = getUnorderedList(containerUUID);
links = loadLinks(list);
G = linkageToDigraph(links);

if nargin==1
    setappdata(fig,'digraph',G);
end