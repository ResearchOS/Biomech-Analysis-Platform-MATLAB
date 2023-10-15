function [currUUID] = getCurrUUID(uuid)

%% PURPOSE: RETURN THE UUID IN THE APPROPRIATE CURRENT UI TREE THAT AN OBJECT IN THE ALL UI TREE IS BEING ASSIGNED TO
% Depends on the class of the UUID and the current subtab

type = deText(uuid);

title = handles.Process.subtabCurrent.SelectedTab.Title;

if isequal(type, 'VR') && isequal(title,'Function')

    currUUID = handles.Process.groupUITree.SelectedNodes.NodeData.UUID;

elseif ismember(type,{'PR','PG'}) && isequal(title,'Group')

    label = handles.Process.currentGroupLabel.Text;
    currUUID = strsplit(label,' ');
    currUUID = currUUID{2};

elseif ismember(type,{'PG'}) && isequal(title,'Analysis')

    currUUID = getCurrent('Current_Analysis');

elseif ismember(type,{'PR'}) && isequal(title,'Analysis')

    selNode = handles.Process.analysisUITree.SelectedNodes.NodeData.UUID;
    [~, list] = getUITreeFromNode(selNode);
    
    if length(list)>2
        selNode = list(2); % Parent node.
        currUUID = selNode.NodeData.UUID; % PG
    else
        currUUID = getCurrent('Current_Analysis');
    end
end