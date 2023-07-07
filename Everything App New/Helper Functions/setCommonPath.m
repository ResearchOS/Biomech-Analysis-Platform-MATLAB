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

try
    save(rootSettingsFile,'commonPath','-v6','-append');
catch
    [rootSettingsFolder]=fileparts(rootSettingsFile);
    warning('off','MATLAB:MKDIR:DirectoryExists');
    mkdir(rootSettingsFolder);
    warning('on','MATLAB:MKDIR:DirectoryExists');
    Store_Settings=false;
    save(rootSettingsFile,'commonPath','Store_Settings','-v6'); % This is where the file is first created.
end

initializeClassFolders();