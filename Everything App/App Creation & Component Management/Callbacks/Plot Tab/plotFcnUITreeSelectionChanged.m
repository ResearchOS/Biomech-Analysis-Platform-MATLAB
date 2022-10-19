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
    % Assign all of the axes to the proper handles
    for i=1:length(Q.Children)
        currAxTag=Q.Children(i).Tag;
        axLetter=strfind(currAxTag,' ');
        axLetter=currAxTag(axLetter+1:end);
        Plotting.Plots.(plotName).Axes.(axLetter).Handle=Q.Children(i);
        axHandle=Q.Children(i);
        % Need to look at each modified property of the current axes to see if labels have been modified, and assign those to new handles too.
%         changedProps=Plotting.Plots.(plotName).Axes.(axLetter).ChangedProperties;
%         for propNumAx=1:length(changedProps)
%             propNames=changedProps{propNumAx};
%             for propNum=1:length(propNames)
%                 propName=propNames{propNum};
%                 if ishandle(axHandle.(propName))
%                     % Assign the axes handle property to the modified property.
%                     fldNames=fieldnames(axHandle.(propName));
%                     for fldNum=1:length(fldNames)
%                         fldName=fldNames{fldNum};
%                         axHandle.(propName).(fldName)=Plotting.Plots.(plotName).Axes.(axLetter).Properties.(propName).(fldName);
%                     end
%                 end
%             end
%         end

        idxToDelete=[];
        for j=1:length(axHandle.Children)

            currCompTag=axHandle.Children(j).Tag;
            if isempty(currCompTag)    
                idxToDelete=[idxToDelete; j];
                continue;
            end
            spaceIdx=strfind(currCompTag,' ');
            compName=currCompTag(1:spaceIdx-1);
            compLetter=currCompTag(spaceIdx+1:end);
            Plotting.Plots.(plotName).(compName).(compLetter).Handle=axHandle.Children(j);

        end
        delete(axHandle.Children(idxToDelete)); % Soft reset for the plot, removing erroneous components. May have downstream side effects, not sure.
    end
    
    set(Q.Children,'Parent',handles.Plot.plotPanel);    
    setappdata(fig,'Plotting',Plotting);
    close(Q);
catch
end
drawnow;

% refreshPlotComp(src,[],plotName);