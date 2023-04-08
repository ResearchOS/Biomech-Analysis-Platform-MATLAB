function []=initProjectSettingsFile(projectSettingsFile)

%% PURPOSE: CREATE THE PROJECT SETTINGS FILE IF IT DOES NOT EXIST

[projectSettingsFolder,~]=fileparts(projectSettingsFile);

if exist(projectSettingsFolder,'dir')~=7
    mkdir(projectSettingsFolder);
end

if exist(projectSettingsFile,'file')~=2
    projectSettings.ProcessQueue={};
    writeJSON(projectSettingsFile,projectSettings);
else
    projectSettings=loadJSON(projectSettingsFile);
end

projectPath=getProjectPath(1);

if isempty(projectPath)
    return;
end

%% If there are no existing process group settings files, then create a 'Default' group
% 1. Does Current_ProcessGroup_Name exist in the root settings file?
% 2. Is there a PI processGroup file?

% 2. 
processGroups=getClassFilenames('ProcessGroup');
if ~isfield(projectSettings,'Current_ProcessGroup_Name') || isempty(processGroups)
    processGroupStruct=createProcessGroupStruct('Default'); % This also means that there is not a project-specific process group file
    processGroupStruct_PS=createProcessGroupStruct_PS(processGroupStruct);

    Current_ProcessGroup_Name=processGroupStruct_PS.Text;
    projectSettings=loadJSON(projectSettingsFile);
    projectSettings.Current_ProcessGroup_Name=Current_ProcessGroup_Name;
    writeJSON(projectSettingsFile,projectSettings);    
end

%% If there are no existing plot settings files, then create a 'Default' plot
plots=getClassFilenames('Plot');
if ~isfield(projectSettings,'Current_Plot_Name') || isempty(plots)
    plotStruct=createPlotStruct('Default');
    plotStruct_PS=createPlotStruct_PS(plotStruct);

    Current_Plot_Name=plotStruct_PS.Text;
    projectSettings=loadJSON(projectSettingsFile);
    projectSettings.Current_Plot_Name=Current_Plot_Name;
    writeJSON(projectSettingsFile,projectSettings);    
end