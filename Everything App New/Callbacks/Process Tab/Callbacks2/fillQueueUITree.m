function [] = fillQueueUITree(src, uuid)

%% PURPOSE: FILL THE QUEUE UI TREE FOR THE SPECIFIED ANALYSIS UUID

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Fill the queue UI tree
delete(handles.Process.queueUITree.Children);
queue = getCurrent('Process_Queue');
if isempty(queue)
    queue = {};
end
if ~iscell(queue)
    queue = {queue};
end
queueNames = getName(queue);
for i=1:length(queueNames)
    addNewNode(handles.Process.queueUITree, queue{i}, queueNames{i});
end