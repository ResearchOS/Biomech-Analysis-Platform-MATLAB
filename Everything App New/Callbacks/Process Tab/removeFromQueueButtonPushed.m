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

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);

if ~isfield(projectSettings,'ProcessQueue')
    error(['Check for ''ProcessQueue'' field in settings file at: ' projectSettingsFile]);
end

texts={checkedNodes.Text}';

queue=projectSettings.ProcessQueue;

queue=queue(~ismember(queue,texts));

projectSettings.ProcessQueue=queue;

writeJSON(projectSettingsFile,projectSettings);

delete(handles.Process.queueUITree.Children);

for i=1:length(queue)
    uitreenode(handles.Process.queueUITree,'Text',queue{i});
end