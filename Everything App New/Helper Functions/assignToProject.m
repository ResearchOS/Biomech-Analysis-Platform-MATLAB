function []=assignToProject(struct)

%% PURPOSE: ASSIGN A NEWLY CREATED CLASS STRUCT TO THE CURRENT PROJECT.

slash=filesep;

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');
currentProject=Current_Project_Name;

commonPath=getCommonPath();
projectClassFolder=[commonPath slash 'Project'];
projectStructPath=[projectClassFolder slash 'Project_' currentProject '.json'];

projectStruct=loadJSON(projectStructPath);

linkClasses(struct, projectStruct);