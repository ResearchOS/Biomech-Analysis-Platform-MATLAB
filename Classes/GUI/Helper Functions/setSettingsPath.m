function []=setSettingsPath()

%% PURPOSE: PROMPT THE USER FOR THE SETTINGS PATH

slash=filesep;

root=userpath;

rootSettingsFolder=[root slash 'PGUI Settings'];
rootSettingsFile=[rootSettingsFolder slash 'Settings.mat'];

settingsPath=0;
while settingsPath==0
    settingsPath=uigetdir(cd,'Select Path to Save Settings');
end

if ~isfolder(rootSettingsFolder)
    mkdir(rootSettingsFolder);
end

save(rootSettingsFile,'settingsPath','-v6');