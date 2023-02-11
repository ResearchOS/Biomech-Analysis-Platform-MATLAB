function []=groupUITreeSelectionChanged(src,event)

%% PURPOSE: SHOW THE CURRENT FUNCTION'S VARIABLES IN THE FUNCTIONS UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.groupUITree.SelectedNodes;

if isempty(selNode)
    return;
end

if ~isequal(selNode.NodeData.Class,'Process')
    delete(handles.Process.functionUITree.Children);
    return;
end

% Requires a Process function to be selected
fillCurrentFunctionUITree(fig);

%% Update which specifyTrials are checked.
fullPath=getClassFilePath_PS(selNode.Text, 'Process');

processStruct=loadJSON(fullPath);

specifyTrials=processStruct.SpecifyTrials;

specifyTrialsUITree=handles.Process.allSpecifyTrialsUITree;

checkSpecifyTrialsUITree(specifyTrials, specifyTrialsUITree);