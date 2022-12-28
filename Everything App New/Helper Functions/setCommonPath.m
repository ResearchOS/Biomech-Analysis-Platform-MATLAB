function []=setCommonPath(fig)

%% PURPOSE: PROMPT THE USER FOR THE SETTINGS PATH
handles=getappdata(fig,'handles');

slash=filesep;

root=userpath;

rootSettingsFolder=[root slash 'PGUI Settings'];
commonPathFile=[rootSettingsFolder slash 'Settings.mat'];

commonPath=0;
while commonPath==0
    commonPath=uigetdir(cd,'Select Path to Save Settings');
end

if ~isfolder(rootSettingsFolder)
    mkdir(rootSettingsFolder);
end

save(commonPathFile,'commonPath','-v6');

% %% Initialize the projectNames .mat file - what was this supposed to do
% again?
% projectsMetadata=struct([]);
% projectNamesPath=[commonPath slash 'projectsMetadata.mat'];
% if ~isfile(projectNamesPath)
%     save(projectNamesPath,'projectsMetadata','-v6');
% end

%% Create the class variables folders if they do not already exist.
classNames=getappdata(fig,'classNames');
for i=1:length(classNames)
    className=classNames{i};

    classFolder=[commonPath slash className];

    if ~isfolder(classFolder)
        mkdir(classFolder);
    end

    addpath(genpath(classFolder));
end

%% Put the common path into the edit field
handles.Settings.commonPathEditField.Value=commonPath;