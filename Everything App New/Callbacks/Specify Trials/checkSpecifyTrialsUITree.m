function []=checkSpecifyTrialsUITree(specifyTrials, specifyTrialsUITree)

%% PURPOSE: CHANGE WHICH NODES ARE CHECKED AFTER THE CURRENTLY SELECTED OBJECT HAS CHANGED.

if isempty(specifyTrialsUITree.Children)
    specifyTrialsTexts={};
else
    specifyTrialsTexts={specifyTrialsUITree.Children.Text};
end

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