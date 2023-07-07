function []=setCommonPath(commonPath)

%% PURPOSE: PROMPT THE USER FOR THE SETTINGS PATH. THIS IS STORED WITH THE COMPUTER'S ID TO FACILITATE SHARING THE SETTINGS FILE BETWEEN COMPUTERS.

rootSettingsFile=getRootSettingsFile();

computerID = getComputerID();

if nargin==0
    commonPathNew=uigetdir(cd,'Select Path to Save Settings');
end

try
    load(rootSettingsFile,'commonPath');
catch
    
end

if commonPath==0
    commonPath.(computerID)=userpath; % If no common path is selected, it will just default to the MATLAB default userpath.
end

commonPath.(computerID) = commonPathNew;

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