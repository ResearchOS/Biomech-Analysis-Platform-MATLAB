function []=specifyTrialsUITreeCheckedNodesChanged(src,event)

%% PURPOSE: CHANGE WHICH SPECIFY TRIALS ARE BEING RUN FOR THE CURRENT CLASS.

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

tab=handles.Tabs.tabGroup1.SelectedTab.Title;

%% Get which class is currently being modified. Only depends on tab name.
switch tab
    case 'Import'
        class='Logsheet';        
    case 'Process'
        class='Process';        
    case 'Plot'
        class='Plot';        
end

%% Get the UI tree of the class that is currently selected.
switch class
    case 'Logsheet'
        uiTree=handles.Import.allLogsheetsUITree;
    case 'Process'
        currTab = handles.Process.subtabCurrent.SelectedTab.Title;
        switch currTab
            case 'Analysis'
                uiTree = handles.Process.analysisUITree;
            case 'Group'
                uiTree=handles.Process.groupUITree;
            case 'Function'
                uiTree=handles.Process.groupUITree;
        end
end

classNode = uiTree.SelectedNodes;

if isempty(classNode)
    src.CheckedNodes = [];
    return;
end

classUUID = classNode.NodeData.UUID;

selSTNode = src.SelectedNodes;

if isempty(selSTNode)
    return;
end

checkedIdx = ismember(selSTNode, src.CheckedNodes);

% If unchecking the box, remove it from the list.
[type] = deText(classUUID);
if ~ismember(type,{'PR','LG'})
    return;
end

stUUID = selSTNode.NodeData.UUID;

st = getST(classUUID);

if checkedIdx
    st = [st; {stUUID}];
else
    st(ismember(st,stUUID)) = [];
end

%% Put the specify trials in the object's SQL table.
tableName = getTableName(type, true);
sqlquery = ['UPDATE ' tableName ' SET SpecifyTrials = ''' jsonencode(st) ''' WHERE UUID = ''' classUUID ''';'];
execute(conn, sqlquery);

if ~any(checkedIdx)
    return;
end

%% Put the specify trials in this analysis.
Current_Analysis = getCurrent('Current_Analysis');
linkObjs(stUUID, Current_Analysis);