function []=importSearchFieldValueChanging(src,event)

%% PURPOSE: CHANGE THE SEARCH TERM

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

searchTerm=getSearchTerm(handles.Import.searchField);

fillUITree(fig,'Logsheet',handles.Import.allLogsheetsUITree, ...
    searchTerm, handles.Import.sortLogsheetsDropDown);