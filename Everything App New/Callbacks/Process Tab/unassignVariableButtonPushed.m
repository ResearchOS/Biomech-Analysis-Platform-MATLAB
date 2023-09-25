function []=unassignVariableButtonPushed(src,event)

%% PURPOSE: UNASSIGN VARIABLE FROM CURRENT PROCESSING FUNCTION

global globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% Current process group UI tree
currFcnNode = handles.Process.groupUITree.SelectedNodes;

if isempty(currFcnNode)
    return;
end

currFcnUUID = currFcnNode.NodeData.UUID;

% Current process UI tree
processUITree=handles.Process.functionUITree; 

currVarNode=processUITree.SelectedNodes;

if isempty(currVarNode)
    return;
end

varNameInCode = strsplit(currVarNode.Text);
varNameInCode = varNameInCode{1};

currVarUUID = currVarNode.NodeData.UUID;

parentNode = currVarNode.Parent;
if isequal(parentNode,processUITree)
    disp('Must select an individual argument, not the getArg/setArg parent node!');
    return;
end

if isequal(parentNode.Text(1:6),'getArg')
    % fldName = 'InputVariables';
    % absFldName = 'InputVariablesNamesInCode';
    isOut = false;
elseif isequal(parentNode.Text(1:6),'setArg')
    % fldName = 'OutputVariables';
    % absFldName = 'OutputVariablesNamesInCode';
    isOut = true;
end

%% Unlink the variable from the PR.
preds = predecessors(globalG, currVarUUID);
if isOut
    unlinkObjs(currFcnUUID,currVarUUID);    
else
    unlinkObjs(currVarUUID, currFcnUUID);    
end

currVarNode.Text = varNameInCode;
currVarNode.NodeData.UUID = '';

%% Check if the previous variable should be removed from the current analysis
anList = getObjs(preds, 'AN', 'down');
Current_Analysis = getCurrent('Current_Analysis');
if ~ismember(Current_Analysis,anList)
    unlinkObjs(currVarUUID, Current_Analysis); % The unlinked variable is no longer part of this analysis.
end 

% Set out of date for PR & its VR
setObjsOutOfDate(fig, currFcnUUID, true);

%% Update the digraph
toggleDigraphCheckboxValueChanged(fig);



