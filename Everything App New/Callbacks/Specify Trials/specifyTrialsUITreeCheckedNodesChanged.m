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

%% Put the specify trials in this analysis.
Current_Analysis = getCurrent('Current_Analysis');
if checkedIdx    
    linkObjs(stUUID, Current_Analysis);    
end

%% Put the specify trials in the object's SQL table.
if isequal(type,'LG')
    tableName = getTableName(type, true);
    sqlquery = ['UPDATE ' tableName ' SET SpecifyTrials = ''' jsonencode(st) ''' WHERE UUID = ''' classUUID ''';'];
    execute(conn, sqlquery);
    return;
end

prID = getSelUUID(uiTree);

%% Delete the specifyTrials entries already in the table.
sqlquery = ['DELETE FROM PR_ST_AN WHERE PR_ID = ''' prID ''' AND AN_ID = ''' Current_Analysis ''';'];
execute(conn, sqlquery);

if isempty(st)
    return;
end

sqlquery = ['INSERT INTO PR_ST_AN (PR_ID, ST_ID, AN_ID) VALUES '];
for i=1:length(st)
    str = getCondStr({prID, st{i}, Current_Analysis});
    sqlquery = [sqlquery str ', '];
end
sqlquery = [sqlquery(1:end-2) ';'];
execute(conn, sqlquery);