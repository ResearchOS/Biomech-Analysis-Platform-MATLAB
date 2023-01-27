function []=initProjectSettingsFile(projectSettingsFile,fig)

%% PURPOSE: CREATE THE PROJECT SETTINGS FILE IF IT DOES NOT EXIST

if exist(projectSettingsFile,'file')~=2
    projectSettings.Queue={};
    writeJSON(projectSettingsFile,projectSettings);
    return;
end

assert(exist(projectSettingsFile,'file')==2); % If it did not exist before, it should after the above code.

projectPath=getProjectPath(fig);

if isempty(projectPath)
    existProjectPath=false;
    setappdata(fig,'existProjectPath',existProjectPath);
    return;
end

existProjectPath=true;
setappdata(fig,'existProjectPath',existProjectPath);

%% If there are no existing process group settings files, then create a 'Default' group
% 1. Does Current_ProcessGroup_Name exist in the root settings file?
% 2. Is there a PI processGroup file?

% 2. 
processGroups=getClassFilenames(fig,'ProcessGroup');
if isempty(processGroups) && existProjectPath
    processGroupStruct=createProcessGroupStruct(fig,'Default'); % This also means that there is not a project-specific process group file
    PSprocessGroupStruct=createProcessGroupStruct_PS(fig,processGroupStruct);

    Current_ProcessGroup_Name=PSprocessGroupStruct.Text;
    projectSettings=loadJSON(projectSettingsFile);
    projectSettings.Current_ProcessGroup_Name=Current_ProcessGroup_Name;
    writeJSON(projectSettingsFile,projectSettings);    
end

% 1. 
if existProjectPath    
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
    plotStruct_PS=createPlotStruct_PS(fig,plotStruct);

    Current_Plot_Name=plotStruct_PS.Text;
    projectSettings=loadJSON(projectSettingsFile);
    projectSettings.Current_Plot_Name=Current_Plot_Name;
    writeJSON(projectSettingsFile,projectSettings);    
end

if existProjectPath
    projectSettingsVarNames=loadJSON(projectSettingsFile);
    projectSettingsVarNames=fieldnames(projectSettingsVarNames);
    if ~ismember('Current_Plot_Name',projectSettingsVarNames)
        error('HOW DID THIS HAPPEN? MORE TESTING NEEDED');
    end
end