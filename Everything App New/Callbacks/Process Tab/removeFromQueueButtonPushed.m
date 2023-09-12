function []=removeFromQueueButtonPushed(src,event)

%% PURPOSE: REMOVE THE CURRENT PROCESSING FUNCTION OR GROUP FROM THE QUEUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

checkedNodes=handles.Process.queueUITree.CheckedNodes;

if isempty(checkedNodes)
    remNodes=handles.Process.queueUITree.SelectedNodes;
    if isempty(remNodes)
        return;
    end
else
    remNodes = checkedNodes;    
end

tmp = [remNodes.NodeData];
uuids={tmp.UUID}';

delete(remNodes);

queue = getCurrent('Process_Queue');
if isempty(queue)
    return; % This should never really happen here.
end
if ~iscell(queue)
    queue = {queue};
end

idx = ismember(queue,uuids);

queue(idx) = [];

setCurrent(queue, 'Process_Queue');