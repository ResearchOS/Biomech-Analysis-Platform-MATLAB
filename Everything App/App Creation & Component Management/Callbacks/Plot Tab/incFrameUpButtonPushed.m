function []=incFrameUpButtonPushed(src,event)

%% PURPOSE: INCREMENT THE FRAME NUMBER OF THE PLOT UP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting=getappdata(fig,'Plotting');

newIdx=Plotting.Plots.(plotName).Movie.currFrame+Plotting.Plots.(plotName).Movie.Increment;
if newIdx>Plotting.Plots.(plotName).Movie.endFrame
    return;
end

Plotting.Plots.(plotName).Movie.currFrame=newIdx;

handles.Plot.currFrameEditField.Value=Plotting.Plots.(plotName).Movie.currFrame;

setappdata(fig,'Plotting',Plotting);

currFrameEditFieldValueChanged(fig);