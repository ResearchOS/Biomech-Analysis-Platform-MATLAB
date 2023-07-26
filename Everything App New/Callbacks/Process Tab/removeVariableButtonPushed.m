function []=removeVariableButtonPushed(src,event)

%% PURPOSE: REMOVE A VARIABLE FROM THE LIST.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.allVariablesUITree;

selNode=uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

uuid = selNode.NodeData.UUID;

linksFolder = [getCommonPath() filesep 'Linkages'];
linksFile = [linksFolder filesep 'Linkages.json'];
links = loadJSON(linksFile);
if ismember(uuid,links(:,1)) || ismember(uuid,links(:,2))
    disp('Cannot archive a variable that is being used!');
    return;
end

moveToArchive(uuid);

selectNeighborNode(selNode);
delete(selNode);