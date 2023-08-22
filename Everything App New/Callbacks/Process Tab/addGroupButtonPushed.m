function []=addGroupButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PROCESSING FUNCTION GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

groupName=promptName('Enter Group Name');

if isempty(groupName)
    return;
end

groupStruct = createNewObject(false, 'ProcessGroup', groupName, '', '', true);

addNewNode(handles.Process.allGroupsUITree, groupStruct.UUID, groupStruct.Text);

figure(fig);