function []=changeName(src,event)

%% PURPOSE: CHANGE THE DISPLAY TEXT OF AN OBJECT

fig=ancestor(src,'figure','toplevel');
% handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

uuid = selNode.NodeData.UUID;
struct = loadJSON(uuid);

name = promptName('Enter New Name',struct.Text);

struct.Text = name;
writeJSON(getJSONPath(uuid),struct);
selNode.Text = struct.Text;

figure(fig);