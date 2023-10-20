function [uuid] = processCallbacks(src, event, args)

%% PURPOSE: CONTROLLER FOR PROCESS CALLBACKS.

global globalG viewG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
allHandles = handles;

handles = handles.Process;

if exist('event','var')~=1
    event = '';
end
if exist('args','var')~=1
    args.Type = '';
end
type = args.Type;
subtabTitle = handles.subtabCurrent.SelectedTab.Title;
alltabTitle = handles.subTabAll.SelectedTab.Title;

switch subtabTitle
    case 'Analysis'
        currUITree = handles.analysisUITree;
    case {'Group','Function'}
        currUITree = handles.groupUITree;
end

switch alltabTitle
    case 'Analyses'
        uiTree = handles.allAnalysesUITree;
    case 'Groups'
        uiTree = handles.allGroupsUITree;
    case 'Functions'
        uiTree = handles.allProcessUITree;
    case 'Variables'
        uiTree = handles.allVariablesUITree;
end

if isfield(args,'UITree')
    uiTree = args.UITree;
end
% 
% switch type
%     case {'All_VR','VR'}
%         uiTree = handles.allVariablesUITree;
%         currUITree = handles.functionUITree;
%     case {'All_PR','PR'}
%         uiTree = handles.allProcessUITree;
%         currUITree = handles.functionUITree;
%     case {'All_PG','PG'}
%         uiTree = handles.allGroupsUITree;
%         currUITree = handles.groupUITree;
%     case {'All_AN','AN'}
%         uiTree = handles.allAnalysesUITree;
%         currUITree = handles.analysisUITree;
%     case {'All_ST','ST'}
%         uiTree = handles.allSpecifyTrialsUITree;
%         currUITree = handles.allSpecifyTrialsUITree;
%     otherwise
%         switch subtabTitle
%             case 'Analysis'
%                 currUITree = handles.analysisUITree;
%             case {'Group', 'Function'}
%                 currUITree = handles.groupUITree;
%             % case 'Function'
%             %     currUITree = handles.functionUITree;
%             otherwise
%                 error('What happened?!');
%         end
% end

if isfield(args,'UUID')
    uuid = args.UUID;
else
    if contains(type,'All')
        uuid = getSelUUID(uiTree);
    else
        uuid = getSelUUID(currUITree);
    end
end
if iscell(uuid)
    uuid = uuid{1}; % Shouldn't really happen, but just in case due to changes in getSelUUID
end

if contains(type,'ST')
    uiTree = handles.allSpecifyTrialsUITree;
end

switch src
    case handles.addSpecifyTrialsButton
        addSpecifyTrialsButtonPushed(fig);

    % Add new abstract objects. DONE.
    case {handles.addVariableButton, handles.addProcessButton, handles.addGroupButton, handles.addAnalysisButton}
        createAndShowObject(uiTree, false, type(5:6), '', '', '', true);

    % Delete objects. DONE.
    case {handles.removeVariableButton, handles.removeProcessButton, handles.removeGroupButton, handles.removeAnalysisButton, handles.removeSpecifyTrialsButton}
        node = getNode(uiTree, uuid);
        confirmAndDeleteObject(uuid, node);

    % Change the current analysis. DONE.
    case handles.selectAnalysisButton
        disp('Switching to new analysis!');
        setCurrent(uuid, 'Current_Analysis');
        disp('Filling UI trees');
        fillAnalysisUITree(fig, handles.analysisUITree, uuid); % Still needs to deal with current UI tree titles
        linkObjs(uuid, getCurrent('Current_Project_Name'));
        disp('Initializing views dropdown');
        initViewsDropdown(fig, uuid);
        if handles.toggleDigraphCheckbox.Value
            % args.UUID = getCurrent('Current_View'); % Not really needed for the callback itself, but needed to pass the logic at the beginning of this file.
            processCallbacks(handles.viewsDropDown);
        end
        disp('Filling queue UI tree');
        fillQueueUITree(fig, uuid);
        disp('Filling logsheet UI tree');
        fillLogsheetUITree(fig, uuid);        

    % Fill the group and process UI trees. DONE.
    case handles.analysisUITree
        if isequal(args,'DoubleClick')
            analysisUITreeDoubleClickedFcn(fig);
            return;
        end
        node = getNode(currUITree, uuid);
        nodeType = deText(uuid);
        if isequal(nodeType,'PR')
            node = node.Parent;
            if ~isequal(class(node), 'matlab.ui.container.CheckBoxTree')
                containerUUID = node.NodeData.UUID;
            else
                containerUUID = getCurrent('Current_Analysis');
            end
        else
            containerUUID = uuid;
        end
        fillAnalysisUITree(fig, handles.groupUITree, containerUUID); % Fill the group UI tree.        
        argsOut.Type = 'PG';
        argsOut.UUID = uuid;
        selectNode(handles.groupUITree, uuid);
        processCallbacks(handles.groupUITree, '', argsOut);

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
        isMulti = handles.multiSelectButton.Value;
        if ~isMulti && ~isempty(viewG)
            viewG.Nodes.Selected = false(length(viewG.Nodes.Name),1);
            idx = ismember(viewG.Nodes.Name, uuid);
            viewG.Nodes.Selected(idx) = true;
            renderDigraph(fig, viewG);
        end

    % DONE.
    case handles.functionUITree
        % Do nothing here.

    % Check that there is no overlap between analyses. If so, handle it.
    case {handles.assignVariableButton, handles.unassignVariableButton, ...
            handles.assignFunctionButton, handles.unassignFunctionButton, ...
            handles.assignGroupButton, handles.unassignGroupButton}
        % 1. If abstract node selected, create new instance object (occurs during assignment only).
        uuid = getSelUUID(uiTree);
        % currUUID = getSelUUID(currUITree);
        currUUID = getCurrUUID(uuid, allHandles);

        if ~isInstance(uuid)
            abstractNode = getNode(uiTree, uuid);
            [~, abstractID] = deText(uuid);
            struct = createAndShowObject(abstractNode, true, getClassFromUITree(uiTree), abstractNode.Text, abstractID, '', true);
            uuid = struct.UUID;
        end        
        [lUUID, rUUID] = getLRObjs(allHandles, uuid, currUUID);
        rType = deText(rUUID);

        isMult = checkMultAN(lUUID, rUUID);
        if isMult
            listString = {'Abort the change','Copy to new analysis','Propagate changes to multiple analyses'};
            a = listdlg('PromptString','Make a decision','ListString',listString);
            if isempty(a)
                return; % Cancel
            end
            if contains(listString(a),'Abort') % Abort the change
                return;
            % Duplicate this PR and all downstream nodes in the current
            %   analysis (except the AN itself), and then assign the new VR to
            %   the PR. Don't forget to remove the previous nodes from this AN!
            elseif contains(listString(a),'Copy to new')
                if isequal(rType,'VR')
                    args.UUID = lUUID;
                    lUUID = copyToNewPS(src, args);
                else
                    args.UUID = rUUID;
                    rUUID = copyToNewPS(src, args); % This works for everything except for output variables.
                end
            elseif contains(listString(a),'Propagate') % Make changes to all involved analyses (easy, just proceed with changes to the PR/PG)
            else
                return; % Anything else like cancel or X
            end
        end

        if ismember(src,[handles.assignVariableButton, handles.assignFunctionButton, handles.assignGroupButton])
            linkObjs_showNode(lUUID, rUUID, allHandles);            
        else
            % unlinkObjs_delNode(lUUID, rUUID, allHandles);                                 
        end

    % Assign PR or all PR's in PG to queue
    case handles.addToQueueButton
        uuids = getSelUUID(currUITree);
        if isequal(subtabTitle,'Function')
            uuids = handles.groupUITree.SelectedNodes.NodeData.UUID;
        end
        addToQueueButtonPushed(fig, uuids);

    % Unassign PR's from queue
    case handles.removeFromQueueButton
        removeFromQueueButtonPushed(fig);

    % Edit the specify trials condition selected.
    case handles.editSpecifyTrialsButton
        editSpecifyTrialsButtonPushed(fig);

    % Check specify trials UI tree
    case handles.allSpecifyTrialsUITree
        uuid = getSelUUID(handles.analysisUITree);
        type = deText(uuid);
        if ~isequal(type,'PR')
            handles.specifyTrialsUITree.CheckedNodes = [];
            return;
        end
        specifyTrialsUITreeCheckedNodesChanged(handles.allSpecifyTrialsUITree);

    % Run the queue.
    case handles.runButton
        runButtonPushed(fig);

    % Add args to PR.
    case handles.addArgsButton
        addArgsButtonPushed(fig);

    % Remove args from PR.
    case handles.removeArgsButton
        removeArgsButtonPushed(fig);

    % Show digraph checkbox.
    case handles.toggleDigraphCheckbox
        toggleVisibility_Digraph(allHandles); % Show or hide the graphics objects related to the digraph.   
        if ~src.Value
            return;
        end
        processCallbacks(handles.viewsDropDown); % Render the digraph.

    % Change the current view.
    case handles.viewsDropDown
        % Based on the inclNodes in the current view, make the PR & VR - only digraph, and render it.
        uuid = viewsDropDownValueChanged(fig);        
        vw = loadJSON(uuid);
        % Compute PR & VR - only digraph, with "Selected" column.
        fcnsG = getFcnsOnlyDigraph(globalG);
        if isequal(vw.Abstract_UUID,'VW000000')
            vw.InclNodes = fcnsG.Nodes.Name;
        end
        viewG = getSubgraph(fcnsG, vw.InclNodes, 'none');
        viewG.Nodes.Selected = false(length(viewG.Nodes.Name),1);
        viewG.Nodes.PrettyName = getName(viewG.Nodes.Name);
        viewG.Edges.PrettyName = getName(viewG.Edges.Name);
        % Render the view's graph.
        renderDigraph(fig, viewG);

    % Edit/save view state
    case handles.editViewButton
        % Open the .json file if button state is [false]
        % Close .json and save changes to SQL if button state is [true]
        % Render the digraph.


    % Add node from list to view
    case handles.addToViewButton
        % Get nodes in list to add
        uuids = getSelUUID(currUITree);
        if isequal(subtabTitle,'Function')
            uuids = handles.groupUITree.SelectedNodes.NodeData.UUID;
        end
        if ~iscell(uuids)
            uuids = {uuids};
        end
        vw = loadJSON(getCurrent('Current_View'));
        vw.InclNodes = [vw.InclNodes; uuids];
        saveObj(vw, 'UPDATE');
        processCallbacks(handles.viewsDropDown); % Recompute & render the graph.

    % Remove node from view
    case handles.removeFromViewButton
        uuids = viewG.Nodes.Name(viewG.Nodes.Selected==1);
        vw = loadJSON(getCurrent('Current_View'));
        vw.InclNodes(ismember(vw.InclNodes, uuids)) = [];
        saveObj(vw,'UPDATE');
        processCallbacks(handles.viewsDropDown);

    % New view
    case handles.newViewButton
        uuid = newViewButtonPushed(fig, viewG);
        handles.viewsDropDown.Value = uuid;
        processCallbacks(handles.viewsDropDown);

    % Toggle showing pretty variable names
    case handles.prettyVarsCheckbox
        renderDigraph(fig, viewG);

    % Digraph axes interaction
    case handles.digraphAxes
        isMulti = handles.multiSelectButton.Value;
        ax = handles.digraphAxes;
        uuid = getClickedUUID(ax, viewG);
        idx = ismember(viewG.Nodes.Name, uuid);        
        % Update viewG.
        if ~isMulti && isUUID(uuid)            
            viewG.Nodes.Selected = false(length(viewG.Nodes.Name),1);
            viewG.Nodes.Selected(idx) = true;
            % Change the selection in the current UI trees
            selectNode(handles.analysisUITree, uuid);
            args.UUID = uuid;
            args.Type = 'AN';
            args.UITree = handles.analysisUITree;
            processCallbacks(handles.analysisUITree, '', args);
        else
            % Render digraph.
            viewG.Nodes.Selected(idx) = ~viewG.Nodes.Selected(idx);
            renderDigraph(fig, viewG);
        end                
        handles.subtabCurrent.SelectedTab = handles.currentFunctionTab;

end