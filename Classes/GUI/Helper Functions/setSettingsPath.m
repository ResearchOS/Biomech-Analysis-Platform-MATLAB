function []=setSettingsPath(fig)

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

%% Initialize the projectNames .mat file
projectsMetadata=struct([]);
projectNamesPath=[settingsPath slash 'projectsMetadata.mat'];
if ~isfile(projectNamesPath)
    save(projectNamesPath,'projectsMetadata','-v6');
end

%% Create the class variables folders if they do not already exist.
classNames=getappdata(fig,'classNames');
for i=1:length(classNames)
    className=classNames{i};

    classFolder=[settingsPath slash className];

    if ~isfolder(classFolder)
        mkdir(classFolder);
    end
end