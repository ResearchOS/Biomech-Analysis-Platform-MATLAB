function []=addAxesButtonPushed(src,event)

%% PURPOSE: ADD A NEW AXES COMPONENT TO THE PLOT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Get the current project-specific plot struct.
projectSettingsFile=getProjectSettingsFile;
projectSettings=loadJSON(projectSettingsFile);
plotText=projectSettings.Current_Plot_Name;
fullPath=getClassFilePath(plotText, 'Plot');
plotStructPS=loadJSON(fullPath);

%% Create a new project-specific axes component
compName='Axes';
id='000000'; % Hard-coded
axPathPI=getClassFilePath('Axes_000000','Component');
if exist(axPathPI,'file')~=2
    axStruct=createComponentStruct(compName, id);
else
    axStruct=loadJSON(axPathPI);
end
axStructPS=createComponentStruct_PS(axStruct);
% axPathPS=getClassFilePath(axStructPS.Text, 'Component', fig);

%% Link the new axes component to the current plot
linkClasses(axStructPS, plotStructPS);

searchTerm=getSearchTerm(handles.Plot.plotSearchField);
sortDropDown=handles.Plot.sortComponentsDropDown;

fillUITree(fig, 'Component', handles.Plot.allComponentsUITree, ...
    searchTerm, sortDropDown);

fillPlotUITree(fig);