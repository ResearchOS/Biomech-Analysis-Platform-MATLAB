function []=assignVariableButtonPushed(src,allVarUUID)

%% PURPOSE: ASSIGN VARIABLE TO CURRENT PROCESSING FUNCTION

% RULES FOR ASSIGNING VARIABLES:
% 1. In the code, a variable name must uniquely occur only once among all
% getArg calls. Meaning, a variable named e.g. "mass" can only be mapped to
% one variable object, even across getArg's with different ID's. 
% 2. The same variable can be mapped to multiple names in code.

% motherNode is the "grouping" class object, and daughterNode is the
% "grouped" class object.

% Case 1: Front end: name in code only on node. Back end: No PR & VR record
%   - Link PR & VR, assign the name on the node to it. Update node text.
% Case 2: Front end: name in code & VR name on node. Back end: PR & VR record with name
%   - update VR_ID in record (find with prev VR). Update node text.

%% NOTE: built-in isdag(G) to check if there are cycles in the graph! May be faster than getting run list to do this?

global conn;

disp(['Assigning variable!']);
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% All variables UI tree
allNode=handles.Process.allVariablesUITree.SelectedNodes;

if isempty(allNode)
    disp('No variable selected to assign!');
    return;
end

processUITree=handles.Process.functionUITree;

% Current process group UI tree
currFcnNode = handles.Process.groupUITree.SelectedNodes;

if isempty(currFcnNode)
    disp('No function selected!');
    return;
end

% Current function UI tree
currVarNode=processUITree.SelectedNodes;

if isempty(currVarNode)
    disp('Select a variable to assign to!');
    return;
end

parentNode = currVarNode.Parent;
if isequal(parentNode, processUITree)
    disp('Cannot select the getArg or setArg nodes! Must select the specific variables.');
    return;
end

% Only not true when pasting a variable.
if exist('allVarUUID','var')~=1
    allVarUUID = allNode.NodeData.UUID;    
end
[type, abstractID, instanceID] = deText(allVarUUID);

% Abstract selected. Create new instance.
if isempty(instanceID)
    % Confirm that the user wants to create a new instance
    a = questdlg('Are you sure you want to create a new instance of this object?','Confirm','No');
    if ~isequal(a,'Yes')
        return;
    end
    figure(fig);
    varStruct = createNewObject(true, 'Variable', allNode.Text, abstractID, '', true);
    allVarUUID = varStruct.UUID;
    abstractUUID = genUUID(type, abstractID);
    absNode = selectNode(handles.Process.allVariablesUITree, abstractUUID);

    % Create the new node in the "all" UI tree
    addNewNode(absNode, allVarUUID, varStruct.Text);
end

isOut = false;
if isequal(parentNode.Text(1:6),'getArg')
    tablename = 'VR_PR';
elseif isequal(parentNode.Text(1:6),'setArg')
    isOut = true;
    tablename = 'PR_VR';
end

%% Test that adding this variable to this function does not result in a cyclic graph.
% If so, stop the process.
currFcnUUID = currFcnNode.NodeData.UUID;
prevVarUUID = currFcnNode.NodeData.UUID;
if isempty(prevVarUUID)
    if isOut
        [success, msg] = linkObjs(currFcnUUID, allVarUUID); % Output variable        
    else
        [success, msg] = linkObjs(allVarUUID, currFcnUUID);        
    end
    if ~success
        disp(msg);
        return;
    end
    nameInCode = currFcnNode.Text; % Name in code only, no UUID.
    sqlquery = ['UPDATE ' tablename ' SET NameInCode = ''' nameInCode ''' WHERE PR_ID = ''' currFcnUUID ''' AND VR_ID = ''' allVarUUID ''';'];
    execute(conn, sqlquery);
    currFcnNode.Text = [currFcnNode.Text '(' allVarUUID ')'];
else
    sqlquery = ['UPDATE ' tablename ' SET VR_ID = ''' allVarUUID ''' WHERE PR_ID = ''' currFcnUUID ''' AND VR_ID = ''' prevVarUUID ''';'];
    execute(conn, sqlquery);    
    currVarNode.NodeData.UUID = allVarUUID;
    spaceIdx = strfind(currVarNode.Text,' '); % Should only be one space.
    currVarNode.Text = [currVarNode.Text(1:spaceIdx-1) ' (' allVarUUID ')'];
end

% Set out of date for PR & its VR
refreshDigraph(fig);
setPR_VROutOfDate(fig, currFcnUUID, true, true);

%% Update the digraph
toggleDigraphCheckboxValueChanged(fig);

disp('Finished assigning variable!');