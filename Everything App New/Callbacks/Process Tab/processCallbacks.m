function [] = processCallbacks(src, event, args)

%% PURPOSE: CONTROLLER FOR PROCESS CALLBACKS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
allHandles = handles;

handles = handles.Process;

if exist('event','var')~=1
    event = '';
end
if exist('args','var')~=1
    args = '';
end

switch args
    case 'All_VR'
        uiTree = handles.allVariablesUITree;
    case 'All_PR'
        uiTree = handles.allProcessUITree;
    case {handles.addGroupButton, handles.removeGroupButton, handles.allGroupsUITree}
        uiTree = handles.allGroupsUITree;
    case {handles.addAnalysisButton, handles.removeAnalysisButton, handles.allAnalysesUITree}
        uiTree = handles.allAnalysesUITree;
    case {handles.specifyTrialsUITree, handles.editSpecifyTrialsButton, handles.removeSpecifyTrialsButton, handles.addSpecifyTrialsButton}
        uiTree = handles.specifyTrialsUITree;
    otherwise
        uiTree = handles.analysisUITree;
end

if isfield(args,'UUID')
    uuid = args.UUID;
else
    uuid = getSelUUID(uiTree);
end

if ~isUUID(uuid)
    disp(['Not a UUID! ' uuid]);
    return;
end

switch src
    % Add objects.
    case {handles.addVariableButton, handles.addProcessButton, handles.addGroupButton, handles.addAnalysisButton, handles.addSpecifyTrialsButton}
        % 1. Create the new abstract object.
        struct = createNewObject(false, args(5:6), '', '', '', true);

        % 2. Add it to the UI tree & select it.
        addNewNode(uiTree, struct.UUID, struct.Name);
        selectNode(uiTree, struct.UUID);

    % Delete objects.
    case {handles.removeVariableButton, handles.removeProcessButton, handles.removeGroupButton, handles.removeAnalysisButton, handles.removeSpecifyTrialsButton}
        confirmAndDeleteObject(uuid);

    % Change the current analysis.
    case handles.selectAnalysisButton        
        fillAnalysisUITree(fig, handles.analysisUITree, uuid); % Still needs to deal with current UI tree titles
        linkObjs(uuid, getCurrent('Current_Project_Name'));

    % Fill the group and process UI trees
    case handles.analysisUITree
        fillAnalysisUITree(fig, handles.groupUITree, uuid); % Fill the group UI tree.
        showSpecifyTrials(uuid);
        processCallbacks(handles.groupUITree, '', uuid);        

    % Fill the process UI tree, and select the node in the analysis UI tree too
    case handles.groupUITree
        selectNode(handles.analysisUITree, uuid);
        fillCurrentFunctionUITree(fig, uuid);
        showSpecifyTrials(uuid);

    case handles.processUITree
        % Do nothing here.

    % Check that there is no overlap between analyses. If so, handle it.
    case {handles.assignVariableButton, handles.unassignVariableButton, ...
            handles.assignProcessButton, handles.unassignProcessButton, ...
            handles.assignGroupButton, handles.unassignGroupButton}
        % 1. If abstract node selected, create new instance object (assignment only).

        % 2. Check if the connection would modify an object within another analysis,
        % if so ask the user what they want to do.
        %   a. Make changes to all involved analyses (easy, just proceed with changes to the PR)
        %   b. Abort the change
        %   c. Duplicate this PR and all downstream nodes in the current
        %   analysis (except the AN itself), and then assign the new VR to
        %   the PR. Don't forget to remove the previous nodes from this AN!

        processCallbacks(src, '', args);

    % Assign VR to PR, and to AN.
    case handles.assignVariableButton   
        % 1. Put the VR->PR / PR->VR and VR->AN edge into the SQL database and the digraph.

        % 2. Show the variable in the processUITree next to the correct
        % name in code.

        % 3. If this PR is in the current view, update the view with the
        % new edge.

    % Assign PR to PG.
    case handles.assignProcessButton
        % 1. Put the PR -> PG edge into the SQL database and the digraph

        % 2. Show the PR in the analysis UI tree and the group UI tree

    % Assign PG to PG or AN.
    case handles.assignGroupButton
        % 1. Put the PG -> PG / PG -> AN edge into SQL and the digraph.

        % 2. Show the PG and any PR in the analysis UI tree and the group
        % UI tree

    % Assign PR or all PR's in PG to queue
    case handles.assignToQueueButton

    % Unassign PR's from queue
    case handles.unassignFromQueueButton

    % Edit the specify trials condition selected.
    case handles.editSpecifyTrialsButton

    % Run the queue.
    case runButtonPushed
        



end