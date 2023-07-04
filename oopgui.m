function []=oopgui()

%% PURPOSE: IMPLEMENT THE PGUI IN AN OBJECT-ORIENTED FASHION
tic;

%% Ensure that there's max one figure open
a=evalin('base','whos;');
names={a.name};
if ismember('gui',names)
    beep; disp('GUI already open, two simultaneous PGUI windows is not supported');
    return;
end

%% Add all of the appropriate paths to MATLAB search path
currFolder=fileparts(mfilename('fullpath'));
addpath(genpath(currFolder));

%% Create the figure
fig=uifigure('Name','pgui','Visible','on',...
    'Resize','on','AutoResizeChildren','off','SizeChangedFcn',@appResize);
set(fig,'DeleteFcn',@(fig, event) saveGUIState(fig)); % Deletes the gui variable from the base workspace.

handles=initializeComponents(fig); % Put all of the components in their place
setappdata(fig,'handles',handles);
assignin('base','gui',fig); % Put the GUI object into the base workspace.

%% Initialize the class folders and the contents of the root settings file.
initializeClassFolders(); % Initialize all of the folders for all classes in the common path
initRootSettingsFile(); % Initialize the root settings file.
initLinkedObjsFile(); % Initialize the file containing object linkages
initProject_Analysis(); % Make sure that a project & analysis exists
initAbstract_Objs(); % Make sure that every instance has a corresponding abstract object (in case they were deleted, etc.)

%% Load the GUI object settings (i.e. selected nodes in UI trees, checkbox selections, projects to filter, etc.)
loadGUIState(fig);

drawnow;
elapsedTime=toc;
disp(['Elapsed time is ' num2str(round(elapsedTime,2)) ' seconds.']);