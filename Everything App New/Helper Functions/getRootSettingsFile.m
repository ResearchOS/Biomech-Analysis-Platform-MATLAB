function [rootSettingsFile]=getRootSettingsFile()

%% PURPOSE: RETURN THE FILE PATH FOR THIS COMPUTER'S ROOT SETTINGS FILE.

slash=filesep;

root=userpath;

rootSettingsFolder=[root slash 'PGUI_Settings'];

% This is robust, but is slow! I should do this once outside of this function during startup and then never again.
% warning('off','MATLAB:MKDIR:DirectoryExists');
% mkdir(rootSettingsFolder);
% warning('on','MATLAB:MKDIR:DirectoryExists');

rootSettingsFile=[rootSettingsFolder slash 'Settings.mat'];