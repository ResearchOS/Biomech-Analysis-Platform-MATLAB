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

if isequal(psStruct.Class,'Process')
    psStruct.InputSubvariables=piStruct.InputVariablesNamesInCode; % Sets the sizes & indices, need to delete the content though.
    for i=1:length(psStruct.InputSubvariables)
        psStruct.InputSubvariables{i}(2:end)=deal(repmat({''},length(psStruct.InputSubvariables{i})-1,1));
    end
end

saveClass(psStruct);

uitreenode(selNode,'Text',psStruct.Text,'ContextMenu',handles.Process.psContextMenu);