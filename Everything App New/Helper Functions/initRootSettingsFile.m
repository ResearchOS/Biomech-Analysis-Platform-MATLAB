function [rootSettingsFile] = initRootSettingsFile()

%% PURPOSE: INITIALIZE THE VARIABLES WITHIN THE ROOT SETTINGS FILE.

rootSettingsFile=getRootSettingsFile();

try
    load(rootSettingsFile);
catch
    % The file does not exist.
end

if exist('Computer_ID','var')~=1
    Computer_ID = getComputerID();
end

% May need to initialize a project if there is no current project, or the
% current project's file does not exist.
if exist('Current_Project_Name','var')~=1 ... % No current project name
        || exist(getJSONPath(Current_Project_Name),'file')~=2 % File for current project name does not exist.
    
    if exist(getJSONPath(Current_Project_Name),'file')~=2
        [name, abstractID, instanceID] = deText(Current_Project_Name);
    else
        abstractID='';
        instanceID='';
    end
    projectStruct = createNewObject(true, 'Project', 'Default',abstractID,instanceID,true);
%     Current_Project_Name = projectStruct.UUID;
end

if exist('Current_Tab_Title','var')~=1
    Current_Tab_Title = 'Projects';
end

if exist('Store_Settings','var')~=1
    Store_Settings = false;
end

if exist('commonPath','var')~=1
    commonPath = getCommonPath();
end

save(rootSettingsFile,'Computer_ID','commonPath',...
    'Store_Settings','Current_Tab_Title',...
    'Current_Project_Name');