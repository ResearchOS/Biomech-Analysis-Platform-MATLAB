function []=deleteCompButtonPushed(src,event)

%% PURPOSE: DELETE A COMPONENT FROM THE ALL COMPONENTS UI TREE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Plotting=getappdata(fig,'Plotting');

if isempty(handles.Plot.allComponentsUITree.SelectedNodes)
    return;
end

compName=handles.Plot.allComponentsUITree.SelectedNodes.Text;

if ~isfield(Plotting,'Plots')
    Plotting.CompNames=Plotting.CompNames(~ismember(Plotting.CompNames,compName));
    setappdata(fig,'Plotting',Plotting);
    makeCompNodes(fig,1:length(Plotting.CompNames),Plotting.CompNames);
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

Plotting.CompNames=Plotting.CompNames(~ismember(Plotting.CompNames,compName));
setappdata(fig,'Plotting',Plotting);
makeCompNodes(fig,1:length(Plotting.CompNames),Plotting.CompNames);