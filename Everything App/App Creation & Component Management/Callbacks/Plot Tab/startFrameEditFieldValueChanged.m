function []=startFrameEditFieldValueChanged(src,prog)

%% PURPOSE: SET THE START FRAME FOR THE MOVIE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting=getappdata(fig,'Plotting');

value=handles.Plot.startFrameEditField.Value;

if value>handles.Plot.endFrameEditField.Value % Ensure that it is not greater than the end frame
    handles.Plot.startFrameEditField.Value=Plotting.Plots.(plotName).Movie.startFrame;
    return;
end

Plotting.Plots.(plotName).Movie.startFrame=value;
if exist('prog','var')~=1
    prog=0;
end
if prog==0
    Plotting.Plots.(plotName).Movie.startFrameVar='';
end

setappdata(fig,'Plotting',Plotting);