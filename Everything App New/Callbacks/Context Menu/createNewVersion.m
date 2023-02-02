function []=createNewVersion(src,event)

%% PURPOSE: CREATE A NEW PROJECT-SPECIFIC VERSION FROM A PI OBJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

text=selNode.Text;

parent=selNode.Parent;

class=getClassFromUITree(parent);

piPath=getClassFilePath(text, class);
piStruct=loadJSON(piPath);

[psStruct,piStruct]=feval(['create' class 'Struct_PS'],piStruct);

linkClasses(piStruct,psStruct);

uitreenode(selNode,'Text',psStruct.Text,'ContextMenu',handles.Process.psContextMenu);