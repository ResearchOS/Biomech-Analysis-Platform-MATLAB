function []=initLinkedObjsFile()

%% PURPOSE: INITIALIZE THE FILES CONTAINING ALL OF THE OBJECTS THAT ARE LINKED.

slash = filesep;
commonPath = getCommonPath();

linksFolder = [commonPath slash 'Linkages'];
if exist(linksFolder,'dir')~=7
    mkdir(linksFolder);
end

% The projects-analyses file.
linksFile = [linksFolder slash 'Linkages.json'];

if exist(linksFile,'file')~=2
    struct.Links = {};
    writeJSON(linksFile, struct);
    % If there are no existing links, create one between the current
    % analysis & project.
    abstractID = createID_Abstract('Analysis');
    analysis = ['AN' abstractID '_' createID_Instance(abstractID, 'Analysis')];
    analysisName = getCurrent('Current_Analysis_Name');
    projectName = getCurrent('Current_Project_Name');    
    linkObjs(analysisName, projectName);
end