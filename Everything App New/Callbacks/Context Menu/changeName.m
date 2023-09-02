function []=changeName(src, uuid, name)

%% PURPOSE: CHANGE THE DISPLAY TEXT OF AN OBJECT. ALREADY CHANGED IN DATABASE.
% NEEDS TO CHANGE IT IN THE "ALL" TREE, AND THE "CURRENT" TREE(S).

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.
% 
% uuid = selNode.NodeData.UUID;
% struct = loadJSON(uuid);
% 
% name = promptName('Enter New Name',struct.Text);
% 
% if isempty(name)
%     return;
% end
% 
% struct.Text = name;
% writeJSON(struct);

figure(fig);

%% Change the name in the all tree.
type = deText(uuid);
class = className2Abbrev(type);
if isequal(class,'SpecifyTrials')
    tabs = {'Import', 'Process'};
    for i=1:length(tabs)
        tab = tabs{i};
        switch tab
            case 'Import'
                stClass = 'Logsheet';
            case 'Process'
                stClass = 'Process';
        end
        uiTree = getUITreeFromClass(fig, class, 'all', stClass);
        allNode = getNode(uiTree, uuid);
        allNode.Text = struct.Text;
    end
else
    if ~isequal(class,'View')
        uiTree = getUITreeFromClass(fig, class, 'all');
        allNode = getNode(uiTree, uuid);
        allNode.Text = name;
    end
end


%% Change the name in any/all of the current trees
% Analysis node
anNode = getNode(handles.Process.analysisUITree, uuid);
if ~isempty(anNode)
    anNode.Text = name;
end

% Group node
groupNode = getNode(handles.Process.groupUITree, uuid);
if ~isempty(groupNode)
    groupNode.Text = name;
end

%% Change the name in the queue UI tree
queueNode = getNode(handles.Process.queueUITree, uuid);
if ~isempty(queueNode)
    queueNode.Text = name;
end

%% Change the name in the current analysis label.
Current_Analysis = getCurrent('Current_Analysis');
if contains(Current_Analysis,uuid)
    handles.Process.currentAnalysisLabel.Text = [name ' ' uuid];
end

%% Change the name in the current group label.
Current_Group = getCurrentProcessGroup(fig);
if contains(Current_Group,uuid)
    handles.Process.currentProcessGroupLabel.Text = [name ' ' uuid];
end

%% Change the name in the current function label.
Current_Process = getCurrentProcess(fig);
if contains(Current_Process,uuid)
    handles.Process.currentFunctionLabel.Text = [name ' ' uuid];
end

%% Change the name in the digraph
if isequal(type,'PR')
    toggleDigraphCheckboxValueChanged(fig) % Refresh the graph.    
end

%% Change the name in the view drop down
if isequal(type,'VW')
    idx = ismember(handles.Process.viewsDropDown.ItemsData, uuid);
    handles.Process.viewsDropDown.Items{idx} = name;
end