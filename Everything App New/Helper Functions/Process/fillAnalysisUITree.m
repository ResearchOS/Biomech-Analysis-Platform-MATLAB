function []=fillAnalysisUITree(src)

%% PURPOSE: FILL THE CURRENT ANALYSIS UI TREE
global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Current_Analysis = getCurrent('Current_Analysis');
anStruct = loadJSON(Current_Analysis);

%% Get the list of functions & groups in the current analysis. How to order them?
sqlquery = ['SELECT PG_ID FROM AN_PG WHERE AN_ID = ''' anStruct.UUID ''';'];
listPG = fetch(conn, sqlquery);
if isempty(listPG)
    listPG = {};
end
sqlquery = ['SELECT PR_ID FROM AN_PR WHERE AN_ID = ''' anStruct.UUID ''';'];
listPR = fetch(conn, sqlquery);
if isempty(listPR)
    listPR = {};
end
listPR_FromPG = getPRFromPG(listPG); % Get all processing functions in the groups.
list = [listPR_FromPG; listPR]; % All processing functions together (from all groups in current analysis).
links = loadLinks(list); % Convert unordered list of processing functions into a linkage table.
G = linkageToDigraph('PR', list);
orderedList = orderDeps(G,'full');

uiTree = handles.Process.analysisUITree;

% Delete all existing entries in current UI trees.
delete(uiTree.Children);
delete(handles.Process.groupUITree.Children);
delete(handles.Process.functionUITree.Children);
handles.Process.currentGroupLabel.Text = 'Current Group';
handles.Process.currentFunctionLabel.Text = 'Current Process';

for i=1:length(orderedList)
    uuid = list{i};

    % Load every file to read its text. Slow! Should be improved in the
    % future.
    struct = loadJSON(uuid);
    
    addNewNode(uiTree, struct.UUID, struct.Text);

end

handles.Process.subtabCurrent.SelectedTab = handles.Process.currentAnalysisTab;