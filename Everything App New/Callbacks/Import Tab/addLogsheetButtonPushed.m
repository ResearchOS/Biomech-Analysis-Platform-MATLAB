function []=addLogsheetButtonPushed(src,event)

%% PURPOSE: CREATE A NEW LOGSHEET

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

logsheetName=promptName('Enter Logsheet Name');

if isempty(logsheetName)
    return;
end

struct = createNewObject(false, 'Logsheet', logsheetName, '', '', true);

searchTerm=getSearchTerm(handles.Import.searchField);

fillUITree(fig,'Logsheet',handles.Import.allLogsheetsUITree, ...
    searchTerm, handles.Import.sortLogsheetsDropDown);

selectNode(handles.Import.allLogsheetsUITree, struct.UUID);

allLogsheetsUITreeSelectionChanged(fig);

linkObjs(struct.UUID, getCurrent('Current_Analysis'));