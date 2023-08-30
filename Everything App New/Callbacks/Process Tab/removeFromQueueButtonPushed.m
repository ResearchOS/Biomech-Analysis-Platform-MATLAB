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

queue = getCurrent('Process_Queue');
if isempty(queue)
    return; % This should never really happen here.
end

tmp = [remNodes.NodeData];
uuids={tmp.UUID}';

idx = ismember(queue,uuids);

queue(idx) = [];

setCurrent(queue, 'Process_Queue');

delete(remNodes);