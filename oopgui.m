function []=oopgui()

%% PURPOSE: IMPLEMENT THE PGUI IN AN OBJECT-ORIENTED FASHION
fig = findall(0,'Name','pgui');
close(fig); clear fig;
isDel = false;
if isDel
    delete('/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/Biomech-Analysis-Platform/Databases/biomechOS.db');
end
tic;

%% Ensure that there's max one figure open
a=evalin('base','whos;');
names={a.name};
if ismember('gui',names)
    beep; disp('GUI already open, two simultaneous PGUI windows is not supported');
    return;
end

clearAllMemoizedCaches; % Clears memoized caches. Using these caches greatly improves startup time.

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

%% Initialize the SQL database
slash = filesep;
try
    dbFile = getCommonPath();
catch
    dbFolder = [currFolder slash 'Databases'];
    if exist(dbFolder,'dir')~=7
        mkdir(dbFolder);
    end
    dbFile = [dbFolder slash 'biomechOS.db'];
end
DBSetup(dbFile);

%% Load the GUI object settings (i.e. selected nodes in UI trees, checkbox selections, projects to filter, etc.)
loadGUIState(fig);

drawnow;
elapsedTime=toc;
disp(['Elapsed time is ' num2str(round(elapsedTime,2)) ' seconds.']);

if isDel
    transferJSON_SQL;
end