function [currUUID] = getCurrUUID(uuid, handles)

%% PURPOSE: RETURN THE UUID IN THE APPROPRIATE CURRENT UI TREE THAT AN OBJECT IN THE ALL UI TREE IS BEING ASSIGNED TO
% Depends on the class of the UUID and the current subtab

type = deText(uuid);

title = handles.Process.subtabCurrent.SelectedTab.Title;

if isequal(type, 'VR') && isequal(title,'Function')
    currUUID = handles.Process.groupUITree.SelectedNodes.NodeData.UUID;
    return;
end

if ~ismember(type,{'PR','PG'})
    return;
end

if isequal(title,'Group')

    selNode = handles.Process.groupUITree.SelectedNodes;
    label = handles.Process.currentGroupLabel.Text;
    containerUUID = strsplit(label,' ');
    containerUUID = containerUUID{2};

elseif isequal(title,'Analysis')

    selNode = handles.Process.analysisUITree.SelectedNodes;
    containerUUID = getCurrent('Current_Analysis');

end


if isempty(selNode)
    currUUID = containerUUID;
else
    nodeType = deText(selNode.NodeData.UUID);
    if isequal(nodeType,'PR')
        selNode = selNode.Parent;
    end

    if ~isequal(class(selNode),'matlab.ui.container.CheckBoxTree')
        currUUID = selNode.NodeData.UUID;
    else
        currUUID = containerUUID;
    end
end
