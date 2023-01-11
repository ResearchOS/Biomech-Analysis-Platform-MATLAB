function [rootSettingsFile]=getRootSettingsFile()

%% PURPOSE: RETURN THE FILE PATH FOR THIS COMPUTER'S ROOT SETTINGS FILE.

slash=filesep;

root=userpath;

rootSettingsFolder=[root slash 'PGUI_Settings'];

warning('off','MATLAB:MKDIR:DirectoryExists');
mkdir(rootSettingsFolder);
warning('on','MATLAB:MKDIR:DirectoryExists');

rootSettingsFile=[rootSettingsFolder slash 'Settings.mat'];