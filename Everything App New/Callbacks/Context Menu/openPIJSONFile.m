function []=openPIJSONFile(src,event)

%% PURPOSE: OPEN THE PROJECT-INDEPENDENT JSON FILE FOR THE CURRENT PROJECT-SPECIFIC SELECTION.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

[name,id,psid]=deText(selNode.Text);

text=[name '_' id];

uiTree=getUITreeFromNode(selNode);

classType=getClassFromUITree(uiTree);

fullPath=getClassFilePath(text, classType);

if exist(fullPath,'file')~=2
    a=questdlg('File does not exist. Create it?','Missing file','Yes','No','Cancel','No');    
    if ismember(a,{'No','Cancel'})
        return;
    end

    [name,id]=deText(selNode.Text);
    piStruct=feval(['create' classType 'Struct'],name,id);

end

openPathWithDefaultApp(fullPath);