function []=specifyTrialsUITreeCheckedNodesChanged(src,event)

%% PURPOSE: CHANGE WHICH SPECIFY TRIALS ARE BEING RUN FOR THE CURRENT CLASS.

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

checkedIdx = ismember(src.CheckedNodes, selSTNode);

% If unchecking the box, rmove it from the list.
[type] = deText(classUUID);
if ~ismember(type,{'PR','LG'})    
    return;
end

stUUID = selSTNode.NodeData.UUID;

%% Put the objects in the linkage matrix.
if any(checkedIdx) % Checked, link the objects.
    linkObjs(stUUID, classUUID);
else % Unchecked, unlink the objects.
    unlinkObjs(stUUID, classUUID);
end