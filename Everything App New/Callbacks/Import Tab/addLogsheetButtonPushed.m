function []=addLogsheetButtonPushed(src,event)

%% PURPOSE: CREATE A NEW LOGSHEET

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

logsheetName=promptName('Enter Logsheet Name');

if isempty(logsheetName)
    return;
end

struct = createNewObject(true, 'Logsheet', logsheetName, '', '', true);

% Create abstract & instance nodes
absNode = addNewNode(handles.Import.allLogsheetsUITree, struct.Abstract_UUID, struct.Name);
addNewNode(absNode, struct.UUID, struct.Name);

selectNode(handles.Import.allLogsheetsUITree, struct.UUID);

allLogsheetsUITreeSelectionChanged(fig);