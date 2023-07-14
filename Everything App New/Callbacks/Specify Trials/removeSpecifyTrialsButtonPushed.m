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

delete(selNode);