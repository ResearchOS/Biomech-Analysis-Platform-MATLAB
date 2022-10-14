function []=plotFcnUITreeSelectionChanged(src,event)

%% PURPOSE: SWITCH THE COMPONENTS BEING SHOWN IN THE "CURRENT COMPONENTS" UITREE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

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

%% Save the previous plot to file when switching to a new one.
slash=filesep;
codePath=getappdata(fig,'codePath');
folderName=[codePath  'Plot' slash 'Stashed GUI Plots'];
if ~isempty(handles.Plot.plotPanel.Children)    
    prevSelectedPlotName=getappdata(fig,'prevSelectedPlotName');
    drawnow;
    Q=figure('Visible','off');
    set(handles.Plot.plotPanel.Children,'Parent',Q);
%     plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;    
    if ~isfolder(folderName)
        mkdir(folderName);
    end
    if ~isempty(prevSelectedPlotName)
        try
            saveas(Q,[folderName slash prevSelectedPlotName '.fig']);
        catch
            pause(0.5);
            saveas(Q,[folderName slash prevSelectedPlotName '.fig']);
        end
    end
    close(Q);
end

setappdata(fig,'prevSelectedPlotName',plotName);

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
if isfield(Plotting.Plots.(plotName),'ExTrial')
    exTrial=Plotting.Plots.(plotName).ExTrial;
    handles.Plot.exTrialLabel.Text=[exTrial.Subject ' ' exTrial.Trial];
else
    handles.Plot.exTrialLabel.Text='';
end

%% Set the level for the current plot.
if isfield(Plotting.Plots.(plotName),'Metadata') && isfield(Plotting.Plots.(plotName).Metadata,'Level')
    level=Plotting.Plots.(plotName).Metadata.Level;
else
    level='T';
    Plotting.Plots.(plotName).Metadata.Level=level;
    setappdata(fig,'Plotting',Plotting);
end
handles.Plot.plotLevelDropDown.Value=level;

if ~ismember(level,{'T'})
    handles.Plot.exTrialLabel.Text='';
end

%% Set the description for the current plot
try
    desc=Plotting.Plots.(plotName).Metadata.Description;
    handles.Plot.fcnVerDescTextArea.Value=desc;
catch
    handles.Plot.fcnVerDescTextArea.Value='Enter Plot Description Here';
end


%% Load plot from file
delete(handles.Plot.plotPanel.Children);
try
    Q=openfig([folderName slash plotName '.fig']);
    Plotting.Plots.(plotName).Axes.A.Handle=Q.Children; % Needs to be updated for multiple axes. Probably by assigning tags with the axes letters to each axes
    set(Q.Children,'Parent',handles.Plot.plotPanel);    
    setappdata(fig,'Plotting',Plotting);
    close(Q);
catch
end
drawnow;

% refreshPlotComp(src,[],plotName);