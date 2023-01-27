function []=groupUITreeSelectionChanged(src,event)

%% PURPOSE: SHOW THE CURRENT FUNCTION'S VARIABLES IN THE FUNCTIONS UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

fillCurrentFunctionUITree(fig);

%% Update which specifyTrials are checked.
selNode=handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

fullPath=getClassFilePath_PS(selNode.Text, 'Process', fig);

processStruct=loadJSON(fullPath);

specifyTrials=processStruct.SpecifyTrials;

specifyTrialsUITree=handles.Process.allSpecifyTrialsUITree;

checkSpecifyTrialsUITree(specifyTrials, specifyTrialsUITree);