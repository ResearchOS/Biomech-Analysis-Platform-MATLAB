function []=initProjectSettingsFile(projectSettingsFile)

%% PURPOSE: CREATE THE PROJECT SETTINGS FILE IF IT DOES NOT EXIST

[projectSettingsFolder,~]=fileparts(projectSettingsFile);

if exist(projectSettingsFolder,'dir')~=7
    mkdir(projectSettingsFolder);
end

projectSettings=struct();
if exist(projectSettingsFile,'file')==2
    projectSettings=loadJSON(projectSettingsFile);
end

if ~isfield(projectSettings,'Process_Queue')    
    projectSettings.Process_Queue={};
end

if ~isfield(projectSettings,'Current_Analysis')    
    projectSettings.Current_Analysis={};
end

if ~isfield(projectSettings,'Current_Logsheet')    
    projectSettings.Current_Logsheet={};
end

projectPath=getProjectPath(1);

if isempty(projectPath)
    return;
end

writeJSON(projectSettingsFile,projectSettings);

%% If there are no existing analysis files for this project, then create a 'Default' analysis and link it to this project.
if isempty(projectSettings.Current_Analysis)
    anStruct=createNewObject(true, 'Analysis', 'Default');
    projectSettings.Current_Analysis = anStruct.UUID;
    writeJSON(projectSettingsFile,projectSettings);
end
