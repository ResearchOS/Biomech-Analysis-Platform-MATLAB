function []=assignGroupButtonPushed(src,text,parentText)

%% PURPOSE: ASSIGN PROCESSING GROUP TO THE CURRENT GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.allGroupsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

Current_Analysis = getCurrent('Current_Analysis');
anStruct = loadJSON(Current_Analysis);

[type, abstractID, instanceID] = deText(uuid);

% Abstract selected. Create new instance.
if isempty(instanceID)
    % Confirm that the user wants to create a new instance
    a = questdlg('Are you sure you want to create a new instance of this object?','Confirm','No');
    if ~isequal(a,'Yes')
        return;
    end
    pgStruct = createNewObject(true, 'ProcessGroup', selNode.Text, abstractID, '', true);
    uuid = pgStruct.UUID;

    % Fill the UI tree
    class = className2Abbrev(type, true);
    uiTree = handles.Process.allGroupsUITree;
    sortDropDown = handles.Process.sortGroupsDropDown;
    searchTerm = getSearchTerm(handles.Process.groupsSearchField);
    fillUITree(fig, class, uiTree, searchTerm, sortDropDown);
end

%% Add the UUID to the current analysis.
anStruct.RunList = [anStruct.RunList; {uuid}];
writeJSON(getJSONPath(anStruct), anStruct);

%% Fill the current analysis UI tree
fillAnalysisUITree(fig);


