function [] = fillLogsheetUITree(src, uuid)

%% PURPOSE: FILL/SELECT THE LOGSHEETS IN THE LOGSHEET UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Current_Logsheet = getCurrent('Current_Logsheet');
selectNode(handles.Import.allLogsheetsUITree, Current_Logsheet);
allLogsheetsUITreeSelectionChanged(fig);