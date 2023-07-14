function []=removeFromQueueButtonPushed(src,event)

%% PURPOSE: REMOVE THE CURRENT PROCESSING FUNCTION OR GROUP FROM THE QUEUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

checkedNodes=handles.Process.queueUITree.CheckedNodes;

if isempty(checkedNodes)
    checkedNodes=handles.Process.queueUITree.SelectedNodes;
    if isempty(checkedNodes)
        return;
    end
end

queue = getCurrent('Process_Queue');
if isempty(queue)
    return; % This should never really happen here.
end

tmp = [checkedNodes.NodeData];
uuids={tmp.UUID}';

idx = ismember(queue,uuids);

queue(idx) = [];

setCurrent(queue, 'Process_Queue');

delete(checkedNodes);