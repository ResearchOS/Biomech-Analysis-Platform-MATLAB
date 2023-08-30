function []=addToQueueButtonPushed(src,event)

%% PURPOSE: ADD THE CURRENT PROCESSING FUNCTION OR GROUP TO QUEUE
% Uses the reachability matrix using transclosure to determine
% dependencies.

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

containerUUID = getCurrent('Current_Analysis');
G = getappdata(fig,'digraph');
if isempty(G)    
    list = getUnorderedList(containerUUID);
    links = loadLinks(list);
    G = linkageToDigraph(links);
    setappdata(fig,'digraph',G);
end
% Get the reachability matrix for upstream dependencies (where all nodes
% can reach)
[R] = getDeps(G,'up'); % 'up' because I want to know the PR that the current PR's rely on that are not up to date.

% Get the out of date values for all PR instances.
sqlquery = ['SELECT UUID, OutOfDate FROM Process_Instances'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
outOfDateIdx = t.OutOfDate==1;
outOfDateUUID = t.UUID(outOfDateIdx);

idx = ismember(G.Nodes.Name,uuids); % Get UUIDs index in digraph.

% Get the reachable nodes.
reachableIdx = any(R(idx,:),1);
reachableUUIDs = G.Nodes.Name(reachableIdx);

outOfDateDepIdx = ismember(outOfDateUUID, reachableUUIDs); % Find the out of date UUID's in the dependencies list.

outOfDateDeps = outOfDateUUID(outOfDateDepIdx); % Get the out of date dependencies

allUUIDs = [outOfDateDeps; uuids]; % Append the out of date dependencies to the ones specified to add.

runList = getRunList(containerUUID, G);
orderedUUIDsIdx = ismember(runList(:,1), allUUIDs); % In case some out of date PR is between the ones to add.
addUUIDs = runList(orderedUUIDsIdx,1);

%% 6. Uncheck all the nodes that are being added.
handles.Process.analysisUITree.CheckedNodes = [];

%% Append UUIDs to queue, and add new nodes to queue UI tree
queue=[queue; addUUIDs];
names = getName(addUUIDs);
setCurrent(queue, 'Process_Queue');

for i=1:length(addUUIDs)    
    addNewNode(handles.Process.queueUITree, addUUIDs{i}, names{i});
end