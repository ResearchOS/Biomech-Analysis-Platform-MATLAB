function [] = editObj(src,event)

%% PURPOSE: OPEN A POPUP WINDOW TO EDIT THE ATTRIBUTES OF THE SELECTED OBJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

struct = loadJSON(uuid);

appFolder = getappdata(fig,'appFolder');
tmpFolder = [appFolder filesep 'Tmp JSON'];
if ~isfolder(tmpFolder)
    mkdir(tmpFolder);
end

tmpPath = [tmpFolder filesep struct.UUID '.json'];

json = jsonencode(struct);

fid = fopen(tmpPath,'w');

openPathWithDefaultApp(tmpPath);