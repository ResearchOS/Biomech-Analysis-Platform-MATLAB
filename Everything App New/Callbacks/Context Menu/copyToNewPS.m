function []=copyToNewPS(src, event)

%% PURPOSE: COPY THE SPECIFIED PS STRUCT TO A NEW PS STRUCT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

uuid=selNode.NodeData.UUID;

newUUID = copyToNew(uuid, false); % By default, not creating a whole new analysis. In the future, ask the user (or have a default setting)

currentProjectButtonPushed(fig);