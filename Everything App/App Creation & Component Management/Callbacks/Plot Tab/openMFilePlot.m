function []=openMFilePlot(src,event)

%% PURPOSE: OPEN THE M FILE FOR COMPONENTS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

selNode=handles.Plot.allComponentsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

filePath=[getappdata(fig,'codePath') 'Plot' slash 'Components' slash selNode.Text '_P.m'];

if exist(filePath,'file')==2
    edit(filePath);
end