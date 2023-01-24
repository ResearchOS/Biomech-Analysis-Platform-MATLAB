function []=plotUITreeSelectionChanged(src,event)

%% PURPOSE: CHANGE THE COMPONENT UI TREE FOR THE CORRESPONDING COMPONENT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

fillCurrentComponentUITree(fig);

%% Update which specifyTrials are checked.
selNode=handles.Plot.plotUITree.SelectedNodes;

if isempty(selNode)
    return;
end

fullPath=getClassFilePath_PS(selNode.Text, 'Component', fig);

plotStruct=loadJSON(fullPath);

specifyTrials=plotStruct.SpecifyTrials;

specifyTrialsUITree=handles.Plot.allSpecifyTrialsUITree;
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