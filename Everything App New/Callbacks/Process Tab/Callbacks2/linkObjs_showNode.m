function [] = linkObjs_showNode(lUUID, rUUID)

%% PURPOSE: LINK THE OBJECTS TOGETHER, AND CREATE THE NODE IN THE UI TREE.
% THIS MUST BE DONE DIFFERENTLY FOR SOME CLASSES VS. OTHERS.

lType = deText(lUUID);
rType = deText(rUUID);

EndNodes = {lUUID, rUUID};

title = handles.Process.subTabCurrent.SelectedTab.Title;

% VR & PR. (covers input and output variables)
if all(ismember({lType, rType}, {'VR','PR'}))
    selNode = handles.Process.currentFunctionUITree.SelectedNodes;
    nodeText = strsplit(selNode.Text,' ');
    NameInCode = nodeText{1};
    edgeTable = table(EndNodes, NameInCode);
else
    edgeTable = table(EndNodes);
end

linkObjs(edgeTable);

%% Show the node.
if all(ismember({lType, rType}, {'VR', 'PR'})) && isequal(title,'Function')
    if isequal(lType,'VR')
        uuid = lUUID;
    else
        uuid = rUUID;
    end
    selNode.Text = [NameInCode ' (' uuid ')'];
end

% Create the node.
if isequal(title, 'Group')
    uiTree = handles.Process.groupUITree;
    selNode = uiTree.SelectedNodes;
    nodeType = deText(selNode.NodeData.UUID);
    if ~isequal(nodeType,'PG')
        selNode = selNode.Parent;
    end
elseif isequal(title,'Analysis')
    uiTree = handles.Process.analysisUITree;
    selNode = uiTree.SelectedNodes;
    if isequal(rType,'PG')
        if isequal(selNode.NodeData.UUID,'PR')
            selNode = selNode.Parent;
        end
    elseif isequal(rType,'AN')
        if isempty(selNode)
            selNode = uiTree;
        elseif isequal(selNode.NodeData.UUID,'PR')
            selNode = selNode.Parent;
        end
    end
end
node = addNewNode(selNode, lUUID, getName(lUUID));
uiTree.SelectedNodes = node;
processCallbacks(uiTree);

