function []=endFrameEditFieldValueChanged(src,prog)

%% PURPOSE: SET THE END FRAME FOR THE MOVIE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting=getappdata(fig,'Plotting');

value=handles.Plot.endFrameEditField.Value;

if value<handles.Plot.startFrameEditField.Value % Ensure that it is not less than the start frame.
    handles.Plot.endFrameEditField.Value=Plotting.Plots.(plotName).Movie.endFrame;
    return;
end

Plotting.Plots.(plotName).Movie.endFrame=value;
if exist('prog','var')~=1
    prog=0;
end
if prog==0
    Plotting.Plots.(plotName).Movie.endFrameVar='';
end

setappdata(fig,'Plotting',Plotting);