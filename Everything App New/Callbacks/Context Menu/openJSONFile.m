function []=openJSONFile(src,event)

%% PURPOSE: OPEN JSON FILE FOR THE SELECTED NODE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.
uuid = selNode.NodeData.UUID;
[abbrev,abstractID,instanceID]=deText(uuid);
fullPath = getJSONPath(uuid);
class = className2Abbrev(abbrev);

if exist(fullPath,'file')~=2
    a=questdlg('File does not exist. Create it?','Missing file','Yes','No','Cancel','No');    
    if ismember(a,{'No','Cancel'})
        return;
    end

    [~,abstractID]=deText(uuid);
    createNewObject(false, class, selNode.Text, abstractID, '', true);    

end

openPathWithDefaultApp(fullPath);