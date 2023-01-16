function []=addToQueueButtonPushed(src,event)

%% PURPOSE: ADD THE CURRENT PROCESSING FUNCTION OR GROUP TO QUEUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

checkedNodes=handles.Process.groupUITree.CheckedNodes;

if isempty(checkedNodes)
    checkedNodes=handles.Process.groupUITree.SelectedNodes;
    if isempty(checkedNodes)
        return;
    end
end

projectSettingsFile=getProjectSettingsFile(fig);
projectSettings=loadJSON(projectSettingsFile);

if isfield(projectSettings,'ProcessQueue')
    queue={};
else
    queue=projectSettings.ProcessQueue;
end

if ~iscell(queue)
    queue={};
end

texts={checkedNodes.Text}';

inQueueIdx=ismember(texts,queue);

if any(inQueueIdx)
    disp('No action taken. Already present in queue!');
    disp(texts(inQueueIdx));
    beep;
    return;
end

queue=[queue; texts];

projectSettings.ProcessQueue=queue;

writeJSON(projectSettingsFile,projectSettings);

delete(handles.Process.queueUITree.Children);

for i=1:length(queue)
    uitreenode(handles.Process.queueUITree,'Text',queue{i});
end