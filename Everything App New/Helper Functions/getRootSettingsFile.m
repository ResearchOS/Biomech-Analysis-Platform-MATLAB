function [rootSettingsFile]=getRootSettingsFile()

%% PURPOSE: RETURN THE FILE PATH FOR THIS COMPUTER'S ROOT SETTINGS FILE.

slash=filesep;

root=userpath;

rootSettingsFolder=[root slash 'PGUI_Settings'];

rootSettingsFile=[rootSettingsFolder slash 'Settings.mat'];