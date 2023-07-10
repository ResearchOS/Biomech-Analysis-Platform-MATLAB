function []=initProject_Analysis()

%% PURPOSE: ENSURE THAT ANY PROJECT & ANALYSIS EXISTS. DOES NOT LINK THEM.
% Project, analyses
% Exists and is current, exists and is not current, does not exist.

projectName = getCurrent('Current_Project_Name');
anName = getCurrent('Current_Analysis');

projectExist = exist(getJSONPath(projectName),'file')==2;
anExist = exist(getJSONPath(anName),'file')==2;

%% Check if the current computer's paths are present in this project.
if projectExist
    newComputerProjectPaths();
end
 
%% All good, nothing to do here.
if projectExist && anExist
    return;
end

%% PROJECT
% Current project name and/or file is missing. Create a new default project and make that the
% current project.
projCreated = false;
if isempty(projectName) || ~projectExist    
    projCreated = true;
    projectStruct = createNewObject(true, 'Project', 'Default', '','',true);
    setCurrent(projectStruct.UUID, 'Current_Project_Name');
end

%% ANALYSIS
if anExist && ~projCreated
    return; % Analysis was pre-existing and no project was created.
end

% Refresh analysis variables if needed.
if projCreated
    anName = getCurrent('Current_Analysis');
    anExist = exist(getJSONPath(anName),'file')==2;
end

% Current analysis name and/or file is missing.
if isempty(anName) || ~anExist
    anStruct = createNewObject(true, 'Analysis', 'Default', '', '', true);
    setCurrent(anStruct.UUID, 'Current_Analysis');
    if exist('projectStruct','var')~=1
        projectStruct = loadJSON(getCurrent('Current_Project_Name'));
    end
    linkObjs(anStruct, projectStruct);
end