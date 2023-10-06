function []=addToQueueButtonPushed(src,uuids)

%% PURPOSE: ADD THE CURRENT PROCESSING FUNCTION OR GROUP TO QUEUE
% Uses the reachability matrix using transclosure to determine
% dependencies.

global globalG;

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

getDown = questdlg('Add downstream dependencies?','Downstream too?','Yes','No','Cancel','Cancel');
if isequal(getDown,'Cancel') || isempty(getDown)
    return;
end

%% 1. Get the existing queue
queue = getCurrent('Process_Queue');
if isempty(queue)
    queue = {};
end
if ~iscell(queue)
    queue = {queue};
end

%% 2. Add new (selected or checked) PR to the queue
tmp = [addNodes.NodeData];
if nargin==1
    uuids={tmp.UUID}'; % The process functions to add (checked in the process group list)
end

% If a PG is selected and nothing is checked, add its contained PR to the queue.
fcnG = getFcnsOnlyDigraph(globalG);
if isempty(checkedNodes) && any(contains(uuids,'PG')) % Assumes that uuid's is length 1 because only one selection at a time is possible
    assert(length(uuids)==1);
    uuids = predecessors(fcnG, uuids{1});    
    % uuid_Containers = getUnorderedList(uuids{1});
    % uuids = uuid_Containers(:,1);
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

G = globalG;

% Get the out of date values for all PR instances.
% sqlquery = ['SELECT UUID, OutOfDate FROM Process_Instances'];
% t = fetchQuery(sqlquery);
% outOfDateIdx = t.OutOfDate==1;
% outOfDateUUID = t.UUID(outOfDateIdx);

idx = ismember(G.Nodes.Name,uuids); % Get UUIDs index in digraph.

if ~any(idx)
    disp('No inputs or outputs linked to this Process!');
    return;
end

% Get the reachable nodes.
reachableUUIDs = getReachableNodes(G, uuids, 'up');

allOutOfDate = G.Nodes.Name(G.Nodes.OutOfDate==1);

outOfDateDepIdx = ismember(reachableUUIDs, allOutOfDate); % Find the out of date UUID's in the dependencies list.

outOfDateDeps = reachableUUIDs(outOfDateDepIdx); % Get the out of date dependencies

allUUIDs = [outOfDateDeps; uuids]; % Append the out of date dependencies to the ones specified to add.

Current_Analysis = getCurrent('Current_Analysis');
anG = getSubgraph(G, Current_Analysis,'up');
anFcnG = getFcnsOnlyDigraph(anG);
runList = anFcnG.Nodes.Name(toposort(anFcnG));
% runList = getRunList(containerUUID, G);
orderedUUIDsIdx = ismember(runList(:,1), allUUIDs); % In case some out of date PR is between the ones to add.
addUUIDs = runList(orderedUUIDsIdx,1);

%% 6. Uncheck all the nodes that are being added.
handles.Process.analysisUITree.CheckedNodes = [];

% Append UUIDs to queue, and add new nodes to queue UI tree
queue=unique([queue; addUUIDs],'stable');

runListInQueueIdx = ismember(runList(:,1),queue);
queue = runList(runListInQueueIdx); % Same order as run list.

%% If the user wants to add the downstream dependencies too.
if isequal(getDown,'Yes')
    
    reachableUUIDs = getReachableNodes(anFcnG, queue, 'down');

    % outOfDateDepIdx = ismember(outOfDateUUID, reachableUUIDs);
    % 
    % outOfDateDeps = outOfDateUUID(outOfDateDepIdx);

    allUUIDs = [reachableUUIDs; uuids];
    orderedUUIDsIdx = ismember(runList(:,1), allUUIDs); % In case some out of date PR is between the ones to add.
    addUUIDs = runList(orderedUUIDsIdx,1);

    queue=unique([queue; addUUIDs],'stable');

    runListInQueueIdx = ismember(runList(:,1),queue);
    queue = runList(runListInQueueIdx); % Same order as run list.

end

names = getName(queue);
setCurrent(queue, 'Process_Queue');

delete(handles.Process.queueUITree.Children);
for i=1:length(queue)
    addNewNode(handles.Process.queueUITree, queue{i}, names{i});
end