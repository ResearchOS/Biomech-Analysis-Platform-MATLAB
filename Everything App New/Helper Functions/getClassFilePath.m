function [fullPath]=getClassFilePath(selNode,class)

%% PURPOSE: GET THE CLASS FULL FILE PATH FROM THE SELECTED NODE

if isempty(selNode)
    fullPath='';
    return;
end

% This allows this one function to do both project-independent and
% project-specific actions (should be cleaned up in the future.
if ischar(selNode)
    [name, id, psid]=deText(selNode);
    if ~isempty(psid)
        [fullPath]=getClassFilePath_PS(selNode, class);
        return;
    end
end

if ~ischar(selNode)
    parent=selNode.Parent;

    class=getClassFromUITree(parent);

    file=selNode.Text;
else
    file=selNode; % Node text specified directly
end

slash=filesep;

commonPath=getCommonPath();
classFolder=[commonPath slash class];
fullPath=[classFolder slash class '_' file '.json'];