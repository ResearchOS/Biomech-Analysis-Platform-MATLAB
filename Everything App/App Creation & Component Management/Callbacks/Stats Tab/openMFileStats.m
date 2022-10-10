function []=openMFileStats(src,event)

%% PURPOSE: OPEN THE CURRENTLY SELECTED STATS M FILE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Stats.fcnsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

fcnName=selNode.Text;

slash=filesep;

fcnPath=[getappdata(fig,'codePath') 'Statistics' slash fcnName '_Stats.m'];

edit(fcnPath);