function []=editCompButtonPushed(src,event)

%% PURPOSE: EDIT THE CURRENTLY SELECTED COMPONENT
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Plot.currCompUITree.SelectedNodes)
    disp('Select a component first!');
    return;
end

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    disp('Select a plot first!');
    return;
end

Plotting=getappdata(fig,'Plotting');

compNode=handles.Plot.currCompUITree.SelectedNodes;

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

compNames=fieldnames(Plotting.Plots.(plotName));

letter=compNode.Text;
compName=compNode.Parent.Text;

if ~ismember(compName,compNames)
    disp('Need to select the component letter, not the component name!');
    return;
end

if isequal(class(compNode.Parent),'matlab.ui.container.CheckBoxTree')
    disp('Must have a letter selected!');
    return;
end

h=Plotting.Plots.(plotName).(compName).(letter).Handle; % Handle to the hggroup for this component
if ~isequal(compName,'Axes')
    currProps=properties(h.Children(1));
else
    currProps=properties(h);
end

% Edit the current component
editCompPopupWindow(fig,h,currProps,compName,plotName,letter);