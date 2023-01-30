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

psStruct=feval(['create' class 'Struct_PS'],piStruct);

uitreenode(selNode,'Text',psStruct.Text,'ContextMenu',handles.Process.psContextMenu);