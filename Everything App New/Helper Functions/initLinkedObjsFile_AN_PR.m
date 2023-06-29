function []=initLinkedObjsFile_AN_PR()

%% PURPOSE: INITIALIZE THE FILES CONTAINING ALL OF THE OBJECTS THAT ARE LINKED.
% Project-analyses: Relates projects to analyses.


% NOTE THAT THIS FILE DOES NOT REPRESENT OBJECTS ITSELF, JUST THE LINKAGES
% BETWEEN OBJECTS. THEREFORE ITS FOLDER & INITIALIZATION IS TREATED DIFFERENTLY.

% Does not require

slash = filesep;
commonPath = getCommonPath();

linksFolder = [commonPath slash 'Linkages'];
if exist(linksFolder,'dir')~=7
    mkdir(linksFolder);
end

% The projects-analyses file.
pr_an_linksFile = [linksFolder slash 'Analyses_Projects.json'];

if exist(pr_an_linksFile,'file')~=2
    pr_an_struct.Links = {};
    writeJSON(pr_an_linksFile, pr_an_struct);
end