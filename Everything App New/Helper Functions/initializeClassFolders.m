function [classNames]=initializeClassFolders(root)

%% PURPOSE: CREATE THE PROJECT-INDEPENDENT CLASS FOLDERS
slash=filesep;

classNames={'Variable','Plot','PubTable','StatsTable','Component','Project','Process','Logsheet','ProcessGroup','SpecifyTrials'}; % One folder for each object type

if nargin==0
    root=getCommonPath; % Make project-independent folders.
end

for i=1:length(classNames)
    className=classNames{i};

    classFolder=[root slash className];
    archiveFolder=[classFolder slash 'Archive'];

    if ~isfolder(classFolder)
        mkdir(classFolder);
    end
    
    if ~isfolder(archiveFolder)
        mkdir(archiveFolder);
    end
    
end

addpath(genpath(root));