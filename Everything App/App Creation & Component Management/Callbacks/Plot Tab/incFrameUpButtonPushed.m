function []=incFrameUpButtonPushed(src,event)

%% PURPOSE: INCREMENT THE FRAME NUMBER OF THE PLOT UP

evalin('base','tic;');
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Plot.plotFcnUITree.SelectedNodes;

if isempty(selNode)
    return;
end

plotName=selNode.Text;

Plotting=getappdata(fig,'Plotting');

newIdx=Plotting.Plots.(plotName).Movie.currFrame+Plotting.Plots.(plotName).Movie.Increment;
if newIdx>Plotting.Plots.(plotName).Movie.endFrame
    return;
end

Plotting.Plots.(plotName).Movie.currFrame=newIdx;

handles.Plot.currFrameEditField.Value=newIdx;

setappdata(fig,'Plotting',Plotting);

currFrameEditFieldValueChanged(fig);