function [fullPath]=getClassFilePath(uuid,class)

%% PURPOSE: GET THE CLASS FULL FILE PATH FROM THE SELECTED NODE

if isempty(uuid)
    fullPath='';
    return;
end

if isstring(uuid)
    uuid=char(uuid);
end

% This allows this one function to do both project-independent and
% project-specific actions (should be cleaned up in the future.
if ischar(uuid)
    [name, abstractID, instanceID]=deText(uuid);
    if ~isempty(instanceID)
        [fullPath]=getClassFilePath_PS(uuid, class);
        return;
    end
end

if ~ischar(uuid)
    node=uuid; % Because a node was passed in.
    parent=node.Parent;

    class=getClassFromUITree(parent);
    uuid=node.NodeData.UUID;

    file=uuid;
    [type,abstractID,instanceID]=deText(uuid);
else
    file=uuid; % Node text specified directly
end

slash=filesep;

commonPath=getCommonPath();
classFolder=[commonPath slash class];
if isempty(instanceID)
    fullPath=[classFolder slash file '.json'];
else
    fullPath=[classFolder slash 'Instances' slash file '.json'];
end