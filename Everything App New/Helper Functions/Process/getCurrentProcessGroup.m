function [Current_ProcessGroup_Name]=getCurrentProcessGroup()

%% PURPOSE: RETURN THE CURRENT PROCESS GROUP PS NAME FOR THE CURRENT PROJECT.

projectSettingsFile=getProjectSettingsFile();
if isempty(projectSettingsFile)
    Current_ProcessGroup_Name='';
    return;
end
projectSettings=loadJSON(projectSettingsFile);

Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;