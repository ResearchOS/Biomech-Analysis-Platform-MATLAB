function [uuid] = processCallbacks(src, event, args)

%% PURPOSE: CONTROLLER FOR PROCESS CALLBACKS.

global globalG;

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
    case {'All_VR','VR'}
        uiTree = handles.allVariablesUITree;
    case {'All_PR','PR'}
        uiTree = handles.allProcessUITree;
    case {'All_PG','PG'}
        uiTree = handles.allGroupsUITree;
    case 'All_AN'
        uiTree = handles.allAnalysesUITree;
    case 'All_ST'
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
    % Add new abstract objects. DONE.
    case {handles.addVariableButton, handles.addProcessButton, handles.addGroupButton, handles.addAnalysisButton, handles.addSpecifyTrialsButton}
        createAndShowObject(uiTree, false, args(5:6), '', '', '', true);

    % Delete objects. DONE.
    case {handles.removeVariableButton, handles.removeProcessButton, handles.removeGroupButton, handles.removeAnalysisButton, handles.removeSpecifyTrialsButton}
        node = getNode(uiTree, uuid);
        confirmAndDeleteObject(uuid, node);

    % Change the current analysis. DONE.
    case handles.selectAnalysisButton
        fillAnalysisUITree(fig, handles.analysisUITree, uuid); % Still needs to deal with current UI tree titles
        linkObjs(uuid, getCurrent('Current_Project_Name'));

    % Fill the group and process UI trees. DONE.
    case handles.analysisUITree
        if isequal(args,'DoubleClick')
            analysisUITreeDoubleClickedFcn(fig);
            return;
        end
        fillAnalysisUITree(fig, handles.groupUITree, uuid); % Fill the group UI tree.
        processCallbacks(handles.groupUITree, '', uuid);        

    % Fill the process UI tree, and select the node in the analysis UI tree
    % too. DONE.
    case handles.groupUITree
        if isequal(args,'DoubleClick')
            groupUITreeDoubleClicked(fig);
            return;
        end
        selectNode(handles.analysisUITree, uuid);
        st = getST(uuid);
        checkSpecifyTrialsUITree(st, handles.allSpecifyTrialsUITree);
        fillCurrentFunctionUITree(fig, uuid);        

    % DONE.
    case handles.functionUITree
        % Do nothing here.

    % Check that there is no overlap between analyses. If so, handle it.
    case {handles.assignVariableButton, handles.unassignVariableButton, ...
            handles.assignProcessButton, handles.unassignProcessButton, ...
            handles.assignGroupButton, handles.unassignGroupButton}
        % 1. If abstract node selected, create new instance object (occurs during assignment only).        
        if ~isInstance(uuid)
            abstractNode = getNode(uiTree, uuid);
            struct = createAndShowObject(abstractNode, true, getClassFromUITree(uiTree), abstractNode.Text, uuid, '', true);
            uuid = struct.UUID;
        end
        currUUID = getCurrUUID(uuid);
        [lUUID, rUUID] = getLRObjs(uuid, currUUID);

        isMult = checkMultAN(lUUID, rUUID);
        if isMult
            listString = {'Abort the change','Copy to new analysis','Propagate changes to multiple analyses'};
            a = listdlg('PromptString','Make a decision','ListString',listString);
            if contains(a,'Abort') % Abort the change
                return;
            % Duplicate this PR and all downstream nodes in the current
            %   analysis (except the AN itself), and then assign the new VR to
            %   the PR. Don't forget to remove the previous nodes from this AN!
            elseif contains(a,'Copy to new') % 
                [lUUID, rUUID] = '';
            elseif contains(a,'Propagate') % Make changes to all involved analyses (easy, just proceed with changes to the PR/PG)
            else
                return; % Anything else like cancel or X
            end
        end

        if ismember(src,{handles.assignVariableButton, handles.assignProcessButton, handles.assignGroupButton})
            linkObjs_showNode(lUUID, rUUID);            
        else
            unlinkObjs(uuid, currUUID);
                                  
        end

    % Assign PR or all PR's in PG to queue
    case handles.assignToQueueButton

    % Unassign PR's from queue
    case handles.unassignFromQueueButton

    % Edit the specify trials condition selected.
    case handles.editSpecifyTrialsButton
        editSpecifyTrialsButtonPushed(fig);

    % Run the queue.
    case handles.runButtonPushed
        runButtonPushed(fig);

    % Show digraph
    case handles.toggleDigraphCheckbox
        val = 'off';
        if src.Value
            val = 'on';
        end
        handles.Ax.Visible = val;
        



end