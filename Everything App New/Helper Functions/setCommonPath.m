function []=setCommonPath(fig)

%% PURPOSE: PROMPT THE USER FOR THE SETTINGS PATH
handles=getappdata(fig,'handles');

slash=filesep;

rootSettingsFile=getRootSettingsFile();

commonPath=uigetdir(cd,'Select Path to Save Settings');

if commonPath==0
    commonPath=userpath; % If no common path is selected, it will just default to the MATLAB default userpath.
end

save(rootSettingsFile,'commonPath','-v6');

%% Create the class variables folders if they do not already exist.
classNames=getappdata(fig,'classNames');
initializeClassFolders(classNames,commonPath);

%% Put the common path into the edit field
handles.Settings.commonPathEditField.Value=commonPath;