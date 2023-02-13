function [dataPath]=getDataPath(suppress,Current_Project_Name)

%% PURPOSE: RETURN THE PATH TO THE DATA FOLDER FOR THIS COMPUTER.

rootSettingsFile=getRootSettingsFile();

if exist('Current_Project_Name','var')~=1
    load(rootSettingsFile,'Current_Project_Name');
end
fullPath=getClassFilePath(Current_Project_Name,'Project');
struct=loadJSON(fullPath);
computerID=getComputerID();

dataPath='';

if ~isfield(struct.DataPath,computerID)
    if nargin==0 % To not redundantly show this message when starting the app.
        disp('Select a path for the current project!');
    end
    return;
end

dataPath=struct.DataPath.(computerID);

if exist(dataPath,'dir')~=7
    if nargin==0
        disp('Select a path for the current project!');
    end
    dataPath='';
    return;
end