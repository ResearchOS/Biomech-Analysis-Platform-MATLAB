function []=currFrameEditFieldValueChanged(src,event)

%% PURPOSE: UPDATE THE PLOT FOR THE CURRENT FRAME

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting=getappdata(fig,'Plotting');

value=handles.Plot.currFrameEditField.Value;

if value<handles.Plot.currFrameEditField.Value
    handles.Plot.currFrameEditField.Value=Plotting.Plots.(plotName).Movie.currFrame;
    return;
end

Plotting.Plots.(plotName).Movie.currFrame=value;

setappdata(fig,'Plotting',Plotting);

if ~isfield(Plotting.Plots.(plotName),'Axes')
    disp('Add an axes to the current plot!');
    return;
end

selNode=handles.Plot.currCompUITree.Children;

assert(isequal(selNode.Text,'Axes'));

refreshAllSubComps(fig,[],selNode);
