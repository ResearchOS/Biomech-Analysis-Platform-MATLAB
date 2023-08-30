function []=openMFile(src,event)

%% PURPOSE: OPEN THE ASSOCIATED .M FILE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

uuid=selNode.NodeData.UUID;

[type,abstractID,instanceID]=deText(uuid);

if ~isempty(instanceID)
    uuid = genUUID(type, abstractID);
end

struct = loadJSON(uuid);

if ~isfield(struct,'ExecFileName') || isempty(struct.ExecFileName)
    mkNewMFile(struct, struct.Name);
    return;
end

mkNewMFile(struct);

end

function [fileName]=mkNewMFile(struct, fileName)

if nargin==1
    fileName = struct.ExecFileName;
end

oldDir=cd([getCommonPath filesep 'Code']);
try
    filePath=which(fileName);
    edit(filePath);
    cd(oldDir);
    return;
catch % The file does not exist.
    cd(oldDir);
end

%% Create new file
fileName=inputdlg('M file does not exist, create it?','Create new M file?',[1 50],{fileName});
if isempty(fileName)
    return;
end
fileName=fileName{1};
[type] = deText(struct.UUID);
filePath = createMFile(fileName, className2Abbrev(type, true), struct.Level);

%% Assign the file to the current struct.
struct.ExecFileName = fileName;
writeJSON(struct);
edit(filePath);

end