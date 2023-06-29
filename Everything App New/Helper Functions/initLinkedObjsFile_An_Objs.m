function [] = initLinkedObjsFile_An_Objs()

%% PURPOSE: INITIALIZE THE ANALYSES-SPECIFIC FILES AFTER THE ROOT SETTINGS FILE HAS BEEN INITIALIZED
% AT THIS POINT A PROJECT AND ANALYSIS HAVE FOR SURE BEEN CREATED

% Analyses files: Relates objects to one another within each analysis.

slash = filesep;
commonPath = getCommonPath();

linksFolder = [commonPath slash 'Linkages'];

% The analysis-specific file
rootSettingsFile = getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');
projectStruct = loadJSON(getJSONPath(Current_Project_Name));
Current_Analysis = projectStruct.Current_Analysis;
an_linksFilePath = [linksFolder slash Current_Analysis '.json'];

if exist(an_linksFilePath,'file')~=2
    an_links.Links = {};
    writeJSON(an_linksFilePath, an_links);
end