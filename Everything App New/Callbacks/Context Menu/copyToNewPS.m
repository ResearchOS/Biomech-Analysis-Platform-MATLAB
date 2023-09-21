function []=copyToNewPS(src, event)

%% PURPOSE: COPY THE SPECIFIED PS STRUCT TO A NEW PS STRUCT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

uuid=selNode.NodeData.UUID;

% Get the selected nodes in the digraph.
% G = getappdata(fig,'viewG');
% markerSize = getappdata(fig,'markerSize');
% if isempty(G) || (all(markerSize==4) || isempty(selNode))
%     return;
% end
% 
% uuids = G.Nodes.Name(markerSize==8);
% 
% if ~ismember(uuid, uuids)
%     error('How is the clicked on PR not part of the selected group?!');
% end

newUUIDs = copyToNew(uuid, false); % By default, not creating a whole new analysis. In the future, ask the user (or have a default setting)

Current_View = getCurrent('Current_View');
struct = loadJSON(Current_View);
struct.InclNodes = [struct.InclNodes; newUUIDs];
writeJSON(struct);

refreshDigraph(fig);

currentProjectButtonPushed(fig);