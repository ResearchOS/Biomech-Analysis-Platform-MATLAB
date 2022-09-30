function []=deletePlotButtonPushed(src,event)

%% PURPOSE: DELETE A COMPONENT FROM THE ALL COMPONENTS UI TREE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

if ~isfield(Plotting,'Plots')
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

if ~isfield(Plotting.Plots,plotName)
    makePlotNodes(fig,1:length(fieldnames(Plotting.Plots)),fieldnames(Plotting.Plots));
    return;
end

a=questdlg({'Are you sure you want to remove this plot?','This will delete all data associated with this plot'});

if ~isequal(a,'Yes')
    disp('Plot not deleted');
    return;
end

Plotting.Plots=rmfield(Plotting.Plots,plotName);

makePlotNodes(fig,1:length(fieldnames(Plotting.Plots)),fieldnames(Plotting.Plots));
setappdata(fig,'Plotting',Plotting);