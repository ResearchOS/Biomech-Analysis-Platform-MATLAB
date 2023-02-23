function []=copyText(src,event)

%% PURPOSE: COPY THE TEXT OF A NODE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

uiTree=getUITreeFromNode(selNode);
nodeData=selNode.NodeData;

checkedNodes=uiTree.CheckedNodes;

if ~ismember(selNode,checkedNodes)
    if ~isempty(selNode.NodeData)
        class=selNode.NodeData.Class;
    else
        class=getClassFromUITree(uiTree);
    end
    text=selNode.Text;
    clipboard('copy',['Class: ' class ' Text: ' text]);
    return;
end

str='';
for i=1:length(checkedNodes)
    currNode=checkedNodes(i);
    if ~isempty(currNode.NodeData)
        class=currNode.NodeData.Class;
    else
        class=getClassFromUITree(uiTree);
    end
    text=currNode.Text;
    suffix=['Class: ' class ' Text: ' text];
    if i>1
        str=[str newline suffix]; % Newline to separate the nodes.
    else
        str=suffix;
    end

end

clipboard('copy',str);