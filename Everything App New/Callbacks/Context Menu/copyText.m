function []=copyText(src,event)

%% PURPOSE: COPY THE UUID OF A NODE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

selUUID=selNode.NodeData.UUID;

clipboard('copy',selUUID);