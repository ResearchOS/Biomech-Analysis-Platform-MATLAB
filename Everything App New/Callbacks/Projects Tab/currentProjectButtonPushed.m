function []=currentProjectButtonPushed(src)

%% PURPOSE: SELECT THE CURRENT PROJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Projects.allProjectsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

undoRedoStack = getappdata(fig,'undoRedoStack');


% Include name & UUID because the name isn't guaranteed to be unique
uuid = selNode.NodeData.UUID;
[type, abstractID, instanceID] = deText(uuid);
if isempty(instanceID)
    return;
end

handles.Projects.projectsLabel.Text=[selNode.Text ' ' uuid];

setCurrent(uuid, 'Current_Project_Name');

%% Fill the "ALL" UI trees with objects from the current analysis.
sortDropDowns=[handles.Process.sortVariablesDropDown; handles.Process.sortProcessDropDown;
    handles.Process.sortGroupsDropDown; handles.Import.sortLogsheetsDropDown; handles.Process.sortAnalysesDropDown];
uiTrees=[handles.Process.allVariablesUITree; handles.Process.allProcessUITree;
    handles.Process.allGroupsUITree; handles.Import.allLogsheetsUITree; handles.Process.allAnalysesUITree];
classNamesUITrees={'Variable','Process',...
    'ProcessGroup','Logsheet','Analysis'};

for i=1:length(classNamesUITrees)
    class=classNamesUITrees{i};
    uiTree=uiTrees(i);
    sortDropDown=sortDropDowns(i);
    
    fillUITree(fig, class, uiTree, '', sortDropDown);    
end

fillUITree_SpecifyTrials(fig); % Fill in the specify trials

%% Select the current analysis node, and show its entries.
Current_Analysis = getCurrent('Current_Analysis');

selectNode(handles.Process.allAnalysesUITree, Current_Analysis);
selectAnalysisButtonPushed(fig);