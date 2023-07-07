function [commonPath]=getCommonPath()

%% PURPOSE: RETURN THE PATH TO THE DIRECTORY WHERE THE PGUI SETTINGS FILES ARE STORED.
rootSettingsFile=getRootSettingsFile();

%% Root settings contains all of the Settings variables
try
    load(rootSettingsFile,'commonPath');
    computerID = getComputerID();
    commonPath = commonPath.(computerID);
catch e
    if ~ismember(e.identifier,{'MATLAB:load:couldNotReadFile','MATLAB:nonExistentField'}) % If the file does not exist or the computerID field is missing for this computer.
        error(e); % Some other error occurred.
    end

    setCommonPath();
    commonPath = getCommonPath;
end