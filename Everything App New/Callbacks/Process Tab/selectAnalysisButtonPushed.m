function []=selectAnalysisButtonPushed(src)

%% PURPOSE: SHOW THE ENTRIES FOR THE CURRENTLY SELECTED ANALYSIS.

global conn;

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

% Link the current analysis to the current project
Current_Project = getCurrent('Current_Project_Name');
linkObjs(Current_Analysis, Current_Project);

Current_View = getCurrent('Current_View');
% ONLY NEEDED FOR OBJECTS TRANSFERRED OVER FROM JSON
if isequal(Current_View,'NULL')
    setCurrent(Current_View,'Current_View');
    % linkObjs(Current_Analysis, Current_View);
end

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


% % Current_View does not exist, but uuids are not empty. Select "ALL" view.
% if isempty(Current_View) && ~isempty(uuids)
%     idx = ismember(viewNames,'ALL');
%     Current_View = uuids{idx};
% end

% Current_View does not exist, and uuids are empty. Make new view?
% if isempty(Current_View) && isempty(uuids)
%     error('How did this happen?');
% end
% setCurrent('Current_View',Current_View);

idx = ismember(uuids,Current_View);
handles.Process.viewsDropDown.Value = uuids{idx};
viewsDropDownValueChanged(fig);

%% Fill the "ALL" UI trees with objects from the current analysis.
sortDropDowns=[handles.Process.sortVariablesDropDown; handles.Process.sortProcessDropDown;
    handles.Process.sortGroupsDropDown];
uiTrees=[handles.Process.allVariablesUITree; handles.Process.allProcessUITree;
    handles.Process.allGroupsUITree];
classNamesUITrees={'Variable','Process',...
    'ProcessGroup'};

for i=1:length(classNamesUITrees)
    class=classNamesUITrees{i};
    uiTree=uiTrees(i);
    sortDropDown=sortDropDowns(i);
    
    fillUITree(fig, class, uiTree, '', sortDropDown);    
end

fillUITree_SpecifyTrials(fig); % Fill in the specify trials

% Fill the current analysis UI tree
fillAnalysisUITree(fig);