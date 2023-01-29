function [filePath]=getProjectSettingsFile()

%% PURPOSE: GET THE CURRENT PROJECT'S SETTINGS FILE.

slash=filesep;

projectPath=getProjectPath(1);

if isempty(projectPath)
    filePath='';
    return;
end

filePath=[projectPath slash 'Project_Settings' slash 'ProjectSettings.json'];