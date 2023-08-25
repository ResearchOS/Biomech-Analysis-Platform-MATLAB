function []=fillProcessGroupUITree(src, prUUID)

%% PURPOSE: FILL THE CURRENT GROUP UI TREE.
% Check if the specified function is in a group. If so, populate that
% group. If not, just put in that function name. Update the group label to
% reflect the current group name, or no group name.

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree = handles.Process.groupUITree;

sqlquery = ['SELECT PG_ID FROM PG_PR WHERE PR_ID = ''' prUUID ''';'];
t = fetch(conn, sqlquery);
group = table2MyStruct(t);
pgUUID = group.PG_ID;

if isempty(pgUUID) % Function does not belong to a group.
    runList = {prUUID};
else
    % Get all of the group and function names in the group
    runList = getRunList(prUUID);    
end

pgStruct=loadJSON(pgUUID);

[abbrev] = deText(initUUID);

handles.Process.currentGroupLabel.Text = [pgStruct.Name ' ' pgUUID];

delete(uiTree.Children);

% Get all of the names of the objects in the ordered list
sqlquery = ['SELECT UUID, Name FROM ProcessGroup_Instances;'];
t = fetch(conn, sqlquery);
tList = table2MyStruct(t);
[a,b,idx] = intersect(tList.UUID,runList); % FIX THIS
nameList = tList.Name(idx); % Fix this too

for i=1:length(runList)
    uuid = runList{i};

    newNode = addNewNode(uiTree, uuid, nameList{i});
    assignContextMenu(newNode,handles);

    [abbrev] = deText(uuid);

    if isequal(abbrev,'PG') % ProcessGroup
        uuids = createProcessGroupNode(newNode,uuid,handles);
    end  

end

%% Select the corresponding processing node in the graph.
obj=get(fig,'CurrentObject');
if ~isequal(class(obj),'matlab.ui.control.UIAxes')
    if nargin==2
        digraphAxesButtonDownFcn(src, prUUID);
    end
end

%% Select the corresponding node in the UI tree
if nargin == 2
    if ~isequal(abbrev,'PG')
        selectNode(handles.Process.groupUITree,runList{end}); % Can't select a processing group.
    else
        selectNode(handles.Process.groupUITree, prUUID);
    end
end

groupUITreeSelectionChanged(fig);