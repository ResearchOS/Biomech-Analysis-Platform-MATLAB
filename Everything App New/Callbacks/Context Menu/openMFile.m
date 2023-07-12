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

if ~isfield(struct,'MFileName') || isempty(struct.MFileName)
    disp('No M file specified!')
    return;
end

fileName = struct.MFileName;

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
[type] = deText(uuid);
filePath = createMFile(fileName, className2Abbrev(type, true));

%% Assign the file to the current struct.
uuid.MFileName = fileName;
writeJSON(getJSONPath(struct), struct);
edit(filePath);