function []=openMFilePlot(src,event)

%% PURPOSE: OPEN THE M FILE FOR COMPONENTS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

slash=filesep;

selNode=handles.Plot.allComponentsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

Plotting=getappdata(fig,'Plotting');

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

isMovie=Plotting.Plots.(plotName).Movie.IsMovie;

if isMovie==0
    filePath=[getappdata(fig,'codePath') 'Plot' slash 'Components' slash selNode.Text '_P.m'];
else
    filePath=[getappdata(fig,'codePath') 'Plot' slash 'Components' slash selNode.Text '_Movie.m'];
end

if exist(filePath,'file')==2
    edit(filePath);
end