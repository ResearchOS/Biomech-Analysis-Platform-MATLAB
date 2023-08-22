function []=addProcessButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PROCESS FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

processName=promptName('Enter Processing Function Name');

if isempty(processName)
    return;
end

processStruct = createNewObject(false, 'Process', processName, '', '', true);

addNewNode(handles.Process.allProcessUITree, processStruct.UUID, processStruct.Text);

figure(fig);