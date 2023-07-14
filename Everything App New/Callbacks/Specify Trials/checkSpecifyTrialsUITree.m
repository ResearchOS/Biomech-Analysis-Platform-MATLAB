function []=checkSpecifyTrialsUITree(specifyTrials, specifyTrialsUITree)

%% PURPOSE: CHANGE WHICH NODES ARE CHECKED AFTER THE CURRENTLY SELECTED OBJECT HAS CHANGED.

if isempty(specifyTrialsUITree.Children)
    specifyTrialsUITree.CheckedNodes = [];
    return;
end

tmp = [specifyTrialsUITree.Children.NodeData];
uuids = {tmp.UUID};

checkedIdx = ismember(uuids, specifyTrials);

if ~any(checkedIdx)
    specifyTrialsUITree.CheckedNodes = [];
    return;
end

specifyTrialsUITree.CheckedNodes = specifyTrialsUITree.Children(checkedIdx);