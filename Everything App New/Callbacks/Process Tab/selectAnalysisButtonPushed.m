function []=selectAnalysisButtonPushed(src)

%% PURPOSE: SHOW THE ENTRIES FOR THE CURRENTLY SELECTED ANALYSIS.

global conn;

disp('Switching to new analysis!');
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode = handles.Process.allAnalysesUITree.SelectedNodes;

delete(handles.Process.analysisUITree.Children);
if isempty(selNode)    
    handles.Process.currentAnalysisLabel.Text = 'Current Analysis';
    return;
end

uuid = selNode.NodeData.UUID;

[abbrev, abstractID, instanceID] = deText(uuid);

% Check that it's an instance.
if isempty(instanceID)
    return;
end

% Include name & UUID because the name isn't guaranteed to be unique.
handles.Process.currentAnalysisLabel.Text = [selNode.Text ' ' uuid];
Current_Analysis = selNode.NodeData.UUID;
setCurrent(Current_Analysis,'Current_Analysis');

Current_View = getCurrent('Current_View');

% Change the items in the views drop down
sqlquery = ['SELECT VW_ID FROM AN_VW WHERE AN_ID = ''' Current_Analysis ''';'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
uuids = t.VW_ID;
str = getCondStr(uuids);
sqlquery = ['SELECT UUID, Name FROM Views_Instances WHERE UUID IN ' str];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
viewNames = t.Name;

if ~iscell(viewNames)
    viewNames = {viewNames};
    uuids = {t.UUID};
end

handles.Process.viewsDropDown.Items = viewNames;
handles.Process.viewsDropDown.ItemsData = uuids;

idx = ismember(uuids,Current_View);
handles.Process.viewsDropDown.Value = uuids{idx};
viewsDropDownValueChanged(fig);

% Fill the current analysis UI tree
fillAnalysisUITree(fig);
disp('Successfully switched to new analysis');

%% Select the current logsheet.
Current_Logsheet = getCurrent('Current_Logsheet');
selectNode(handles.Import.allLogsheetsUITree, Current_Logsheet);
allLogsheetsUITreeSelectionChanged(fig);