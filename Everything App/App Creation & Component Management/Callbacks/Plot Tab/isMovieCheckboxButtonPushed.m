function []=isMovieCheckboxButtonPushed(src,event)

%% PURPOSE: SELECT WHETHER THE CURRENT PLOT IS A MOVIE OR NOT
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

value=handles.Plot.isMovieCheckbox.Value;

handles.Plot.incEditField.Visible=value;
handles.Plot.incFrameUpButton.Visible=value;
handles.Plot.incFrameDownButton.Visible=value;
handles.Plot.startFrameButton.Visible=value;
handles.Plot.endFrameButton.Visible=value;
handles.Plot.startFrameEditField.Visible=value;
handles.Plot.endFrameEditField.Visible=value;
handles.Plot.currFrameEditField.Visible=value;

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

Plotting=getappdata(fig,'Plotting');

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting.Plots.(plotName).Movie.IsMovie=value;

handles.Plot.incEditField.Value=Plotting.Plots.(plotName).Movie.Increment;
handles.Plot.startFrameEditField.Value=Plotting.Plots.(plotName).Movie.startFrame;
handles.Plot.endFrameEditField.Value=Plotting.Plots.(plotName).Movie.endFrame;
handles.Plot.currFrameEditField.Value=Plotting.Plots.(plotName).Movie.currFrame;

setappdata(fig,'Plotting',Plotting);