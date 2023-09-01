function [] = saveEdits(src,event)

%% PURPOSE: SAVE JSON FILE WITH EDITS TO OBJECT.

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

tmpPath = [tmpFolder filesep struct.UUID '.json'];

if exist(tmpPath,'file')~=2
    disp(['JSON editing file does not exist for UUID = ' uuid]);
    return;
end

a = questdlg([struct.Name ' (' struct.UUID ')'],'Accept changes?','Yes','No','Cancel','No');

if ~isequal(a,'Yes')
    delete(tmpPath);
    return;
end

fid=fopen(tmpPath);
raw=fread(fid,inf);
fclose(fid);
jsonStr=char(raw');
try
    json = jsondecode(jsonStr);
catch
    disp('File does not follow the JSON format!');
    return;
end

if ~isfield(json,'UUID')
    json.UUID = struct.UUID;
end
if ~isfield(json,'Abstract_UUID') && isfield(struct,'Abstract_UUID')
    json.Abstract_UUID = struct.Abstract_UUID;
end

try
    writeJSON(json);
catch
    disp('Failed to write to database! Check column header names and types.');
    return;
end

delete(tmpPath);

% The display name changed, so update the display.
if ~isequal(struct.Name,json.Name)
    fillAnalysisUITree(fig);
end