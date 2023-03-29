function [Current_ProcessGroup_Name]=getCurrentProcessGroup()

%% PURPOSE: RETURN THE CURRENT PROCESS GROUP PS NAME FOR THE CURRENT PROJECT.

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);

Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;