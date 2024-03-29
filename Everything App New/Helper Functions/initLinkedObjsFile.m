function []=initLinkedObjsFile()

%% PURPOSE: INITIALIZE THE FILES CONTAINING ALL OF THE OBJECTS THAT ARE LINKED.
% 4 columns: [Project Analysis ForwardLink BackwardLink];

slash = filesep;
commonPath = getCommonPath();

linksFolder = [commonPath slash 'Linkages'];
if exist(linksFolder,'dir')~=7
    mkdir(linksFolder);
end

linksFile = [linksFolder slash 'Linkages.json'];

if exist(linksFile,'file')~=2
    links = [];
    writeJSON(linksFile, links);
end