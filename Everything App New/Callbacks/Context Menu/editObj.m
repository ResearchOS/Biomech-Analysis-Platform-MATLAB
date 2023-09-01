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

% Don't allow editing UUID & Abstract_UUID
struct = rmfield(struct,'UUID');
if isfield(struct,'Abstract_UUID')
    struct = rmfield(struct,'Abstract_UUID');
end

appFolder = getappdata(fig,'appFolder');
tmpFolder = [appFolder filesep 'Tmp JSON'];
if ~isfolder(tmpFolder)
    mkdir(tmpFolder);
end

tmpPath = [tmpFolder filesep uuid '.json'];

jsonStr = jsonencode(struct,'PrettyPrint',true);

if ~isfile(tmpPath)
    fid = fopen(tmpPath,'w');
    fprintf(fid,'%s',jsonStr);
    fclose(fid);
end

openPathWithDefaultApp(tmpPath);