function []=setCommonPath(commonPath)

%% PURPOSE: PROMPT THE USER FOR THE SETTINGS PATH
% handles=getappdata(fig,'handles');

rootSettingsFile=getRootSettingsFile();

if nargin==0
    commonPath=uigetdir(cd,'Select Path to Save Settings');
end

if commonPath==0
    commonPath=userpath; % If no common path is selected, it will just default to the MATLAB default userpath.
end

save(rootSettingsFile,'commonPath','-v6');

initializeClassFolders(commonPath);