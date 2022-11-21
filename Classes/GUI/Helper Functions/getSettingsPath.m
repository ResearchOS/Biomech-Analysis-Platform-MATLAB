function [settingsPath]=getSettingsPath()

%% PURPOSE: RETURN THE PATH OF THE DIRECTORY WHERE THE PGUI SETTINGS FILES ARE STORED.

slash=filesep;

root=userpath;

rootSettingsFolder=[root slash 'PGUI Settings'];
rootSettingsFile=[rootSettingsFolder slash 'Settings.mat'];

%% Root settings simply contains the path to where all of the Settings variables are stored.
askForPath=0;
try
    load(rootSettingsFile,'settingsPath');
catch e
    if isequal(e.identifier,'MATLAB:load:couldNotReadFile') % If the file does not exist.
        if ~isfolder(rootSettingsFolder)
            mkdir(rootSettingsFolder);
        end
        askForPath=1;
    else
        error(e); % Some other error occurred.
    end
end

if askForPath==1
    settingsPath=uigetdir(cd,'Select Path to Save Settings');
    save(rootSettingsFile,'settingsPath','-v6');
end