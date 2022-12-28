function [commonPath]=getCommonPath(fig)

%% PURPOSE: RETURN THE PATH TO THE DIRECTORY WHERE THE PGUI SETTINGS FILES ARE STORED.

slash=filesep;

root=userpath;

rootSettingsFolder=[root slash 'PGUI Settings'];
rootSettingsFile=[rootSettingsFolder slash 'Settings.mat'];

%% Root settings simply contains the path to where all of the Settings variables are stored.
try
    load(rootSettingsFile,'commonPath');
catch e
    if ~isequal(e.identifier,'MATLAB:load:couldNotReadFile') % If the file does not exist.
        error(e); % Some other error occurred.
    end

    setCommonPath(fig);
    commonPath = getCommonPath;
end