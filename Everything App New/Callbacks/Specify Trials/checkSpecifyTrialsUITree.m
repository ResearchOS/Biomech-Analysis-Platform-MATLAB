function []=checkSpecifyTrialsUITree(specifyTrials, specifyTrialsUITree)

%% PURPOSE: CHANGE WHICH NODES ARE CHECKED AFTER THE CURRENTLY SELECTED OBJECT HAS CHANGED.

specifyTrialsTexts={specifyTrialsUITree.Children.Text};

if isempty(specifyTrials)
    checkedIdx=false;
else
    checkedIdx=ismember(specifyTrialsTexts,specifyTrials);
end

if any(checkedIdx)
    specifyTrialsUITree.CheckedNodes=specifyTrialsUITree.Children(checkedIdx);
else
    specifyTrialsUITree.CheckedNodes=[];
end