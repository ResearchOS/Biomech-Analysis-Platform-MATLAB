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

if isequal(class(compNode.Parent),'matlab.ui.container.CheckBoxTree')
    disp('Must have a letter selected!');
    return;
end

compName=compNode.Parent.Text;

if ~ismember(compName,compNames)
    disp('Need to select the component letter, not the component name!');
    return;
end

h=Plotting.Plots.(plotName).(compName).(letter).Handle; % Handle to the hggroup for this component
if ~isequal(compName,'Axes')
    currProps=properties(h.Children(1));
    newH=h.Children;
else
    currProps=properties(h);
    newH=h;
end

%% Get the list of previously changed properties
if ~isfield(Plotting.Plots.(plotName).(compName).(letter),'ChangedProperties')
    Plotting.Plots.(plotName).(compName).(letter).ChangedProperties=cell(size(newH));
    setappdata(fig,'Plotting',Plotting);
end
propsChangedList=Plotting.Plots.(plotName).(compName).(letter).ChangedProperties;

% Edit the current component
editCompPopupWindow(fig,h,currProps,compName,plotName,letter,propsChangedList);