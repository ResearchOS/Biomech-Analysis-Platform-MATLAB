function []=unassignComponentButtonPushed(src,event)

%% REMOVE THE CURRENTLY SELECTED COMPONENT FROM THE CURRENTLY SELECTED FUNCTION VERSION
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

if isempty(Plotting)
    disp('No plotting info added!');
    return;
end

if isempty(handles.Plot.allComponentsUITree.SelectedNodes)
    disp('Need to select a component!');
    return;
end

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    disp('Need to select a plot!');
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

% compName=handles.Plot.allComponentsUITree.SelectedNodes.Text;

currNode=handles.Plot.currCompUITree.SelectedNodes;
currLetter=currNode.Text;

if ~isequal(class(currNode.Parent),'matlab.ui.container.TreeNode')
    disp('Need to select a letter, not the component itself!');
    return;
end

compName=currNode.Parent.Text;


delete(Plotting.Plots.(plotName).(compName).(currLetter).Handle); % Delete the graphics object.
Plotting.Plots.(plotName).(compName)=rmfield(Plotting.Plots.(plotName).(compName),currLetter);

if isempty(fieldnames(Plotting.Plots.(plotName).(compName)))
    Plotting.Plots.(plotName)=rmfield(Plotting.Plots.(plotName),compName); % If no more of this component in the current plot, remove it entirely.
end

makeCurrCompNodes(fig,Plotting.Plots.(plotName));

setappdata(fig,'Plotting',Plotting);