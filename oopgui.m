function []=oopgui()

%% PURPOSE: IMPLEMENT THE PGUI IN AN OBJECT-ORIENTED FASHION
% Check that the connection is valid or not. Close/delete it so the GUI can open a new clean connection.
global conn;
if ~isempty(conn) && isa(conn,'sqlite')
    if isvalid(conn)
        close(conn); % The processing was stopped in a way that was not just closing the GUI. Most likely during testing/interacting with the code.
    end
    clear global conn;
end

isDel = false;
if isDel
    delete('/Users/mitchelltillman/Desktop/Work/MATLAB_Code/GitRepos/Biomech-Analysis-Platform/Databases/biomechOS.db');
end
tic;

%% Ensure that there's max one figure open
isTest = true;
fig = findall(0,'Name','pgui'); 
if ~isempty(fig)
    if ~isTest
        beep; disp('GUI already open, two simultaneous PGUI windows is not supported');
        return;
    else
        close(fig); clear fig;
    end
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

if isDel
    transferJSON_SQL;
    transferLinks_SQL;
    % transferVarsToNamesInCode;
end

%% Load the GUI object settings (i.e. selected nodes in UI trees, checkbox selections, projects to filter, etc.)
loadGUIState(fig);

drawnow;
elapsedTime=toc;
disp(['Elapsed time is ' num2str(round(elapsedTime,2)) ' seconds.']);