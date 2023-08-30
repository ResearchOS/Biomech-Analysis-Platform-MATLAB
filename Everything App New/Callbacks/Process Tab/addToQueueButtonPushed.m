function []=addToQueueButtonPushed(src,event)

%% PURPOSE: ADD THE CURRENT PROCESSING FUNCTION OR GROUP TO QUEUE
% 1. Get the existing queue.
% 2. Add the new (selected or checked) PR to the queue.
%   - If a PG is selected and nothing is checked, add its PR to the queue.
% 3. Get the highest index of the PR in the queue.
% 4. Check that all PR before it are not out of date.
% 5. If they are out of date, add them to the queue too.
% 6. Uncheck all of the nodes being added.

global conn;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Get the nodes to add. All checked nodes, or if none just a selected node.
checkedNodes=handles.Process.analysisUITree.CheckedNodes;

if isempty(checkedNodes)
    addNodes = handles.Process.analysisUITree.SelectedNodes;
    if isempty(addNodes)
        return;
    end
else
    addNodes = checkedNodes;
end

%% 1. Get the existing queue
queue = getCurrent('Process_Queue');
if isempty(queue)
    queue = '';
end

%% 2. Add new (selected or checked) PR to the queue
tmp = [addNodes.NodeData];
uuids={tmp.UUID}'; % The process functions to add (checked in the process group list)

% If a PG is selected and nothing is checked, add its contained PR to the queue.
if isempty(checkedNodes) && contains(uuids,'PG') % Assumes that uuid's is length 1 because only one selection at a time is possible
    assert(length(uuids)==1);
    uuid_Containers = getUnorderedList(uuids{1});
    uuids = uuid_Containers(:,1);    
end

% Remove everything that's not a process function (like process groups).
processIdx = contains(uuids,'PR');
uuids(~processIdx) = [];

inQueueIdx=ismember(uuids,queue);

if all(inQueueIdx)
    disp('No action taken. Everything already present in queue!');    
    beep;
    return;
end

% Remove the UUID's that are already in the queue.
uuids = uuids(~inQueueIdx);

%% 3. Get the highest index in the run list of the PR in the queue
Current_Analysis = getCurrent('Current_Analysis');
runList = getRunList(Current_Analysis);
idx = find(ismember(runList(:,1),uuids));
maxIdx = max(idx);

%% 4. Check that all dependencies for all PR are up to date. If not, add them to the queue.
sqlquery = ['SELECT UUID, OutOfDate FROM Process_Instances'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
outOfDateIdx = t.OutOfDate==1;
outOfDateUUID = t.UUID(outOfDateIdx);
runListCurr = runList(1:maxIdx,1);

% Obviously it doesn't matter if the PR about to be added to the queue are out of date.
outOfDateUUIDIdxInRunList = ismember(runListCurr(1:maxIdx),outOfDateUUID) & ~ismember(runListCurr(1:maxIdx),uuids);
outdatedUUIDsInRunList = runListCurr(outOfDateUUIDIdxInRunList);
uuids = [outdatedUUIDsInRunList; uuids];

orderedUUIDsIdx = ismember(runListCurr, uuids); % In case some out of date PR is between the ones to add.
addUUIDs = runListCurr(orderedUUIDsIdx);


%% 6. Uncheck all the nodes that are being added.
delIdx=[];
for i=1:length(checkedNodes)
    if ~isempty(checkedNodes(i).Children)
        delIdx=[delIdx; i];
    end
end
checkedNodes(delIdx)=[];

%% Append UUIDs to queue, and add new nodes to queue UI tree
queue=[queue; addUUIDs];
texts = getName(addUUIDs);
setCurrent(queue, 'Process_Queue');

for i=1:length(addUUIDs)    
    addNewNode(handles.Process.queueUITree, addUUIDs{i}, texts{i});
end