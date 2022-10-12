function []=plotLevelDropDownValueChanged(src,event)

%% PURPOSE: SELECT THE LEVEL TO RUN THE CURRENT PLOT OVER.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

selNode=handles.Plot.plotFcnUITree.SelectedNodes;

if isempty(selNode)
    return;
end

plotName=selNode.Text;

level=handles.Plot.plotLevelDropDown.Value;

if Plotting.Plots.(plotName).Movie.IsMovie==1
    level='T';
    handles.Plot.plotLevelDropDown.Value=level; % Movies are only at the trial level
end

Plotting.Plots.(plotName).Metadata.Level=level;

setappdata(fig,'Plotting',Plotting);