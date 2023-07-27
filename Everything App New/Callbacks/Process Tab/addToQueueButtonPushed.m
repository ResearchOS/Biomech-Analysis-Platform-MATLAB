function []=addToQueueButtonPushed(src,event)

%% PURPOSE: ADD THE CURRENT PROCESSING FUNCTION OR GROUP TO QUEUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Get the nodes to add. All checked nodes, or if none just a selected node.
checkedNodes=handles.Process.analysisUITree.CheckedNodes;

if isempty(checkedNodes)
%     checkedNodes=handles.Process.analysisUITree.SelectedNodes;
%     if isempty(checkedNodes)
%         return;
%     end
    return;
end

%% Uncheck all the nodes that are being added.
delIdx=[];
for i=1:length(checkedNodes)
    if ~isempty(checkedNodes(i).Children)
        delIdx=[delIdx; i];
    end
end

checkedNodes(delIdx)=[];

queue = getCurrent('Process_Queue');
if isempty(queue)
    queue = '';
end

tmp = [checkedNodes.NodeData];
uuids={tmp.UUID}'; % The process functions to add (checked in the process group list)
texts = {checkedNodes.Text};

% Remove everything that's not a process function (like process groups).
processIdx = contains(uuids,'PR');
uuids(~processIdx) = [];
texts(~processIdx) = [];

inQueueIdx=ismember(uuids,queue);

if all(inQueueIdx)
    disp('No action taken. Everything already present in queue!');    
    beep;
    return;
end

% Remove the UUID's that are already in the queue.
uuids = uuids(~inQueueIdx);
texts = texts(~inQueueIdx);

%% Check whether all pre-requisite variables are up to date.
% [texts]=checkDeps(texts);

%% Append UUIDs to queue, and add new nodes.
queue=[queue; uuids];
setCurrent(queue, 'Process_Queue');

for i=1:length(uuids)    
    addNewNode(handles.Process.queueUITree, uuids{i}, texts{i});
end