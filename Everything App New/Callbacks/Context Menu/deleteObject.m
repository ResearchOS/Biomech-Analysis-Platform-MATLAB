function []=deleteObject(src,event)

%% PURPOSE: DELETE THE SPECIFIED OBJECT. ALSO REMOVES ALL LINKS TO IT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

text=selNode.Text;

uiTree=getUITreeFromNode(selNode);
class=getClassFromUITree(uiTree);

[name,id,psid]=deText(text);

if isempty(psid)
    isPS=false;
else
    isPS=true;
end

piText=getPITextFromPS(text);
piPath=getClassFilePath(piText,class);
piStruct=loadJSON(piPath);

versions=piStruct.Versions;

% 1. Remove the specified version from the list in the PI struct.
if isPS && ismember(text,versions)
    versions=versions(~ismember(versions,text));
end

% 2. If the text is PI, then delete the entire PI and all versions.
linksNames=contains(fieldnames(piStruct),'Links_'); % The list of class types being linked to and from.