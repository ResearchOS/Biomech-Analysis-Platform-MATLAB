function []=plotFcnUITreeSelectionChanged(src,event)

%% PURPOSE: SWITCH THE COMPONENTS BEING SHOWN IN THE "CURRENT COMPONENTS" UITREE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

delete(handles.Plot.plotPanel.Children);

if isempty(handles.Plot.plotFcnUITree.SelectedNodes)
    delete(handles.Plot.currCompUITree.Children);
    return;
end

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting=getappdata(fig,'Plotting');

if isempty(Plotting) % No components or plots yet. Not sure how this function would have been triggered in this scenario, but covering my bases.
    delete(handles.Plot.currCompUITree.Children);
    return;
end

if ~isfield(Plotting,'Plots') || ~isfield(Plotting.Plots,plotName)
    disp(['Plot ' plotName ' missing metadata! Cannot show components.']);
    delete(handles.Plot.currCompUITree.Children);
    return;
end

compNames=fieldnames(Plotting.Plots.(plotName));

if isempty(compNames) % No components in this plot yet.
    delete(handles.Plot.currCompUITree.Children);
    return;
end

if ~isfield(Plotting.Plots.(plotName),'Movie') || ~isfield(Plotting.Plots.(plotName).Movie,'IsMovie')
    Plotting.Plots.(plotName).Movie.IsMovie=0;
end
handles.Plot.isMovieCheckbox.Value=Plotting.Plots.(plotName).Movie.IsMovie;
isMovie=handles.Plot.isMovieCheckbox.Value;
setappdata(fig,'Plotting',Plotting);
isMovieCheckboxButtonPushed(fig);
if isMovie==1    
    handles.Plot.incEditField.Value=Plotting.Plots.(plotName).Movie.Increment;
    handles.Plot.startFrameEditField.Value=Plotting.Plots.(plotName).Movie.startFrame;
    handles.Plot.endFrameEditField.Value=Plotting.Plots.(plotName).Movie.endFrame;
    handles.Plot.currFrameEditField.Value=Plotting.Plots.(plotName).Movie.currFrame;

end

currPlot=Plotting.Plots.(plotName);
makeCurrCompNodes(fig,currPlot);

refreshPlotComp(src,[],plotName);