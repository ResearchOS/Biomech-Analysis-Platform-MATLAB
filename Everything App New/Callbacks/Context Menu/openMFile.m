function []=openMFile(src,event)

%% PURPOSE: OPEN THE ASSOCIATED .M FILE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

text=selNode.Text;

[name,id,psid]=deText(text);

% Get the current UI tree
if isequal(class(selNode.Parent),'matlab.ui.container.CheckBoxTree')
    parent=selNode.Parent;
else
    parent=selNode.Parent.Parent;
end

if ismember(parent,[handles.Process.groupUITree])
    text=[name '_' id];
end
    
structClass=getClassFromUITree(parent);
fullPath=getClassFilePath(text, structClass);
struct=loadJSON(fullPath);

fileName=struct.MFileName;

try
    filePath=which(fileName);
    edit(filePath);
    return;
catch % The file does not exist.
    disp([fileName ' does not exist or is not on path!']);
end

%% Ask if they want to create a .m file
