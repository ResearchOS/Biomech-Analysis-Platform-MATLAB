function []=changeName(src,event)

%% PURPOSE: CHANGE THE DISPLAY TEXT OF AN OBJECT. NEEDS TO CHANGE IT IN THE "ALL" TREE, AND THE "CURRENT" TREE(S).

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

uuid = selNode.NodeData.UUID;
struct = loadJSON(uuid);

name = promptName('Enter New Name',struct.Text);

if isempty(name)
    return;
end

struct.Text = name;
writeJSON(getJSONPath(uuid),struct);

figure(fig);

%% Change the name in the all tree.
type = deText(uuid);
class = className2Abbrev(type, true);
uiTree = getUITreeFromClass(fig, class, 'all');
allNode = getNode(uiTree, uuid);
allNode.Text = struct.Text;

%% Change the name in any/all of the current trees
% Analysis node
anNode = getNode(handles.Process.analysisUITree, uuid);
if ~isempty(anNode)
    anNode.Text = struct.Text;
end

% Group node
groupNode = getNode(handles.Process.groupUITree, uuid);
if ~isempty(groupNode)
    groupNode.Text = struct.Text;
end

% Function node
fcnNode = getNode(handles.Process.functionUITree, uuid);
if ~isempty(fcnNode)
    fcnNode.Text = struct.Text;
end