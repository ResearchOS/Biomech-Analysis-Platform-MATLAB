function []=editCompButtonPushed(src,event)

%% PURPOSE: EDIT THE CURRENTLY SELECTED COMPONENT
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Plot.currCompUITree.SelectedNodes)
    return;
end

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    return;
end

Plotting=getappdata(fig,'Plotting');

compNode=handles.Plot.currCompUITree.SelectedNodes;

if isequal(class(compNode.Parent),'matlab.ui.container.CheckBoxTree')
    disp('Must have a letter selected!');
    return;
end

letter=compNode.Text;
compName=compNode.Parent.Text;

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

currComp=Plotting.Plots.(plotName).(compName).(letter).Handle;

% Edit the current component
editCompPopupWindow(fig,currComp,compName,plotName,letter);