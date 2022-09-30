function []=deleteCompButtonPushed(src,event)

%% PURPOSE: DELETE A COMPONENT FROM THE ALL COMPONENTS UI TREE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

if isempty(handles.Plot.allComponentsUITree.SelectedNodes)
    return;
end

compName=handles.Plot.allComponentsUITree.SelectedNodes.Text;

if isequal(compName,'Axes')
    disp('Cannot delete the Axes component!');
    return;
end

if ~isfield(Plotting,'Plots')
    idx=~ismember(Plotting.Components.Names,compName);
    Plotting.Components.Names=Plotting.Components.Names(idx);
    Plotting.Components.DefaultProperties=Plotting.Components.DefaultProperties(idx);
    setappdata(fig,'Plotting',Plotting);
    makeCompNodes(fig,1:length(Plotting.Components.Names),Plotting.Components.Names);
end

% Need to check for where this is being used in each individual plot
% doDelete=1; % Initialize that it should be deleted.
plotNames=fieldnames(Plotting.Plots);
for i=1:length(plotNames)
    currPlot=Plotting.Plots.(plotNames{i});

    if isfield(currPlot,compName)
%         doDelete=0;
        disp(['Component not deleted! It is used in plot ' plotNames{i}]);
        return;
    end

end

idx=~ismember(Plotting.Components.Names,compName);
Plotting.Components.Names=Plotting.Components.Names(idx);
Plotting.Components.DefaultProperties=Plotting.Components.DefaultProperties(idx);

setappdata(fig,'Plotting',Plotting);
makeCompNodes(fig,1:length(Plotting.Components.Names),Plotting.Components.Names);