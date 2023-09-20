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
    addNewNode(absNode, allVarUUID, varStruct.Name);
end

isOut = false;
if isequal(parentNode.Text(1:6),'getArg')
    tablename = 'VR_PR';
elseif isequal(parentNode.Text(1:6),'setArg')
    isOut = true;
    tablename = 'PR_VR';
end

%% Check that this variable & PR only belongs to the current analysis. If not, tell the user that if they want to make changes, a new object will be created.
% Or just ask them if they want to propagate the changes to other analyses?
% More advanced option!
currFcnUUID = currFcnNode.NodeData.UUID;
prevVarUUID = currVarNode.NodeData.UUID;

anVR = {};
if isOut
    anVR = getAnalysis(allVarUUID);
end
anPR = getAnalysis(currFcnUUID);
anList = unique([anPR; anVR],'stable');

Current_Analysis = getCurrent('Current_Analysis');

% The VR & PR are found in multiple analyses.
anType = {};
if ~isequal(anList,{Current_Analysis})
    anType = questdlg('Make changes to current analysis only?','Multiple analyses found!','Current','All','Cancel','Current');
    if isempty(anType) || isequal(anType,'Cancel')
        return;
    end
    if isequal(anType,'All')
        % Nothing needed here. Changes made to the current objects will
        % automatically propagate to all analyses.
    end
    if isequal(anType,'Current')        
        % Need to create new versions of this variable (if output) and all
        % downstream PR's and their output variables (and inputs where
        % needed).
        [renamedList, oldList] = newObjVersions(currFcnUUID, anList);
        currFcnIdx = ismember(oldList,currFcnUUID);
        currFcnUUID = renamedList(currFcnIdx);
        allVarIdx = ismember(oldList, allVarUUID);
        allVarUUID = renamedList(allVarIdx);
        prevVarIdx = ismember(oldList,prevVarUUID);
        prevVarUUID = renamedList(prevVarIdx);

        anList = Current_Analysis;

    end
end

%% Add the variable to the function
if isempty(prevVarUUID)
    if isOut
        [success, msg] = linkObjs(currFcnUUID, allVarUUID); % Output variable        
    else
        [success, msg] = linkObjs(allVarUUID, currFcnUUID);        
    end
    % if ~success
    %     disp(msg);
    %     return;
    % end
    currVarNode.NodeData.UUID = allVarUUID;    
    nameInCode = currVarNode.Text;
    sqlquery = ['UPDATE ' tablename ' SET NameInCode = ''' nameInCode ''' WHERE PR_ID = ''' currFcnUUID ''' AND VR_ID = ''' allVarUUID ''' AND NameInCode = ''' nameInCode ''';'];    
    execute(conn, sqlquery);
    currVarNode.Text = [currVarNode.Text ' (' allVarUUID ')'];
else
    spaceIdx = strfind(currVarNode.Text,' '); % Should only be one space.
    nameInCode = currVarNode.Text(1:spaceIdx-1);
    sqlquery = ['UPDATE ' tablename ' SET VR_ID = ''' allVarUUID ''' WHERE PR_ID = ''' currFcnUUID ''' AND VR_ID = ''' prevVarUUID ''' AND NameInCode = ''' nameInCode ''';'];
    execute(conn, sqlquery);    
    currVarNode.NodeData.UUID = allVarUUID;    
    currVarNode.Text = [nameInCode ' (' allVarUUID ')'];
end

% Set out of date for PR & its VR
refreshDigraph(fig);
setPR_VROutOfDate(fig, currFcnUUID, true, true);

if isequal(anType,'Current')
    selectAnalysisButtonPushed(fig);
    return;
end

%% Update the digraph
toggleDigraphCheckboxValueChanged(fig);

disp('Finished assigning variable!');