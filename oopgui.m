function []=oopgui()

%% PURPOSE: IMPLEMENT THE PGUI IN AN OBJECT-ORIENTED FASHION
tic;
% slash=filesep;

classNames={'Variable','Plot','PubTable','StatsTable','Component','Project','Process','Logsheet','ProcessGroup','SpecifyTrials'}; % One folder for each object type

%% Ensure that there's max one figure open
a=evalin('base','whos;');
names={a.name};
if ismember('gui',names)
    beep;
    disp('GUI already open, two simultaneous PGUI windows is not supported');
    return;
end

%% Add all of the appropriate paths to MATLAB search path
currFolder=fileparts(mfilename('fullpath'));
addpath(genpath(currFolder));

%% FOR TESTING ONLY, REMOVE SOON!
rmpath(genpath('/Users/mitchelltillman/Desktop/Stevens_Classes_Research/MATLAB_Code/GitRepos/Biomech-Analysis-Platform/Everything App'));

%% Create the figure
fig=uifigure('Name','pgui','Visible','on',...
    'Resize','on','AutoResizeChildren','off','SizeChangedFcn',@appResize);
set(fig,'DeleteFcn',@(fig, event) saveGUIState(fig));

% Put all of the components in their place
handles=initializeComponents(fig);

setappdata(fig,'handles',handles);
setappdata(fig,'classNames',classNames);

assignin('base','gui',fig); % Put the GUI object into the base workspace.

%% Get the "common path". This is the folder containing project-independent instances of settings class variables.
% This path should be in its own GitHub repository.
commonPath=getCommonPath(fig);
initializeClassFolders(classNames,commonPath);

handles.Settings.commonPathEditField.Value=commonPath; % Put the common path in the GUI.

%% If there are no existing project settings files, then create a 'Default' project
% 1. Does root settings file exist? YES BECAUSE THE COMMON PATH HAS BEEN SET
% 2. Does Current_Project_Name exist in the root settings file?
% 3. Is there a PI projectStruct file?
rootSettingsFile=getRootSettingsFile();
settingsVarNames=whos('-file',rootSettingsFile);
settingsVarNames={settingsVarNames.name};

 % 3.
projects=getClassFilenames(fig,'Project');
if isempty(projects)
    projectStruct=createProjectStruct(fig,'Default');  
    Current_Project_Name=projectStruct.Text;
    save(rootSettingsFile,'Current_Project_Name','-append');
    settingsVarNames=[settingsVarNames {'Current_Project_Name'}];
end

% 2.
if ~ismember('Current_Project_Name',settingsVarNames)
    projects=getClassFilenames(fig,'Project');
    Current_Project_Name=projects{1};
    Current_Project_Name=Current_Project_Name(9:end-5); % Remove 'Project' prefix and '.json' suffix
    save(rootSettingsFile,'Current_Project_Name','-append');
end

%% Get the project path for the current project.
projectPath=getProjectPath(fig,1);
if isempty(projectPath)
    existProjectPath=false;    
else
    existProjectPath=true;    
end
setappdata(fig,'existProjectPath',existProjectPath);

%% If there are no existing process group settings files, then create a 'Default' group
% 1. Does Current_ProcessGroup_Name exist in the root settings file?
% 2. Is there a PI processGroup file?

% 2. 
processGroups=getClassFilenames(fig,'ProcessGroup');
if isempty(processGroups) && existProjectPath
    processGroupStruct=createProcessGroupStruct(fig,'Default'); % This also means that there is not a project-specific process group file
    projectSettingsFile=getProjectSettingsFile(fig); % File stores the current process group name
    PSprocessGroupStruct=createProcessGroupStruct_PS(fig,processGroupStruct);

    Current_ProcessGroup_Name=PSprocessGroupStruct.Text;
    projectSettings=loadJSON(projectSettingsFile);
    projectSettings.Current_ProcessGroup_Name=Current_ProcessGroup_Name;
    writeJSON(projectSettingsFile,projectSettings);    
end

% 1. 
if existProjectPath
    projectSettingsFile=getProjectSettingsFile(fig); % File stores the current process group name
    projectSettingsVarNames=loadJSON(projectSettingsFile);
    projectSettingsVarNames=fieldnames(projectSettingsVarNames);
    if ~ismember('Current_ProcessGroup_Name',projectSettingsVarNames)
        error('HOW DID THIS HAPPEN? MORE TESTING NEEDED');
    end
end

%% If there are no existing plot settings files, then create a 'Default' plot
plots=getClassFilenames(fig,'Plot');
if isempty(plots) && existProjectPath
    plotStruct=createPlotStruct(fig,'Default');
    projectSettingsFile=getProjectSettingsFile(fig);
    plotStruct_PS=createPlotStruct_PS(fig,plotStruct);

    Current_Plot_Name=plotStruct_PS.Text;
    projectSettings=loadJSON(projectSettingsFile);
    projectSettings.Current_Plot_Name=Current_Plot_Name;
    writeJSON(projectSettingsFile,projectSettings);    
end

if existProjectPath
    projectSettingsFile=getProjectSettingsFile(fig); % File stores the current process group name
    projectSettingsVarNames=loadJSON(projectSettingsFile);
    projectSettingsVarNames=fieldnames(projectSettingsVarNames);
    if ~ismember('Current_Plot_Name',projectSettingsVarNames)
        error('HOW DID THIS HAPPEN? MORE TESTING NEEDED');
    end
end

%% Fill the UI trees with their correct values
sortDropDowns=[handles.Projects.sortProjectsDropDown; handles.Import.sortLogsheetsDropDown; 
    handles.Process.sortVariablesDropDown; handles.Process.sortProcessDropDown;
    handles.Plot.sortPlotsDropDown; handles.Plot.sortComponentsDropDown;
    handles.Process.sortGroupsDropDown];
uiTrees=[handles.Projects.allProjectsUITree; handles.Import.allLogsheetsUITree;
    handles.Process.allVariablesUITree; handles.Process.allProcessUITree;
    handles.Plot.allPlotsUITree; handles.Plot.allComponentsUITree;
    handles.Process.allGroupsUITree];
classNamesUITrees={'Project','Logsheet',...
    'Variable','Process',...
    'Plot','Component',...
    'ProcessGroup'};

for i=1:length(classNamesUITrees)
    class=classNamesUITrees{i};
    uiTree=uiTrees(i);
    sortDropDown=sortDropDowns(i);
    
    fillUITree(fig, class, uiTree, '', sortDropDown);    
end

%% Load the GUI object settings (i.e. selected nodes in UI trees, checkbox selections, projects to filter, etc.)
% Stored in a subfolder of the userpath
loadGUIState(fig);

% Runs only the first time that this app is ever used, or just after
% deleting the root settings file.
if ~ismember('Current_Tab_Title',settingsVarNames)
    Current_Tab_Title='Projects';
    save(rootSettingsFile,'Current_Tab_Title');
end

load(rootSettingsFile,'Current_Tab_Title');

handles.Tabs.tabGroup1.SelectedTab=handles.(Current_Tab_Title).Tab;
tabGroup1SelectionChanged(fig); % To allow the variables tab to change parent as needed.
drawnow;
elapsedTime=toc;
disp(['Elapsed time is ' num2str(round(elapsedTime,2)) ' seconds.']);