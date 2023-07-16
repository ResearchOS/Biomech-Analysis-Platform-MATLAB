function []=removeSpecifyTrialsButtonPushed(src,event)

%% PURPOSE: REMOVE A SPECIFY TRIALS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

tab = handles.Tabs.tabGroup1.SelectedTab.Title;
switch tab
    case 'Import'
        stClass = 'Logsheet';
    case 'Process'
        stClass = 'Process';
end

uiTree = getUITreeFromClass(fig, 'SpecifyTrials', 'all', stClass);
selNode = uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

moveToArchive(uuid);

%% Remove the node from each ui tree
tabs = {'Import','Process'};
for i=1:length(tabs)
    tab = tabs{i};
    switch tab
        case 'Import'
            stClass = 'Logsheet';
        case 'Process'
            stClass = 'Process';
    end
    uiTree = getUITreeFromClass(fig, 'SpecifyTrials', 'all', stClass);
    node = getNode(uiTree, uuid);
    delete(node);
end