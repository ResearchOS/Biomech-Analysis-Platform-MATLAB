function []=incEditFieldValueChanged(src,event)

%% PURPOSE: SPECIFY BY HOW MANY FRAMES TO INCREMENT FOR THE MOVIE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

value=handles.Plot.incEditField.Value;

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

if value<1
    handles.Plot.incEditField.Value=Plotting.Plots.(plotName).Movie.Increment;
    return;
end

Plotting.Plots.(plotName).Movie.Increment=value;

setappdata(fig,'Plotting',Plotting);