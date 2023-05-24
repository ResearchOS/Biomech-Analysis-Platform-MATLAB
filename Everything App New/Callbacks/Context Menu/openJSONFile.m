function []=openJSONFile(src,event)

%% PURPOSE: OPEN JSON FILE FOR THE SELECTED NODE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

[name,id,psid]=deText(selNode.Text);

if ~isempty(psid)
    isPS=true;   
    text=[name '_' id '_' psid];    
else
    isPS=false;    
    text=[name '_' id];
end

uiTree=getUITreeFromNode(selNode);

classType=getClassFromUITree(uiTree);

fullPath=getClassFilePath(text, classType);

if exist(fullPath,'file')~=2
    a=questdlg('File does not exist. Create it?','Missing file','Yes','No','Cancel','No');    
    if ismember(a,{'No','Cancel'})
        return;
    end

    if isPS        
        piText=getPITextFromPS(selNode.Text);
        piPath=getClassFilePath(piText, classType);
        [name,id,psid]=deText(selNode.Text);
        if exist(piPath,'file')~=2
            piStruct=feval(['create' classType 'Struct'],name,id);
        else
            piStruct=loadJSON(piPath);
        end

        feval(['create' classType 'Struct_PS'],piStruct,psid);
    else    
        [name,id]=deText(selNode.Text);
        piStruct=feval(['create' classType 'Struct'],name,id);
    end    

end

openPathWithDefaultApp(fullPath);