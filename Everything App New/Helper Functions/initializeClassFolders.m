function []=initializeClassFolders(classNames,root)

%% PURPOSE: CREATE THE PROJECT-INDEPENDENT CLASS FOLDERS
slash=filesep;

for i=1:length(classNames)
    className=classNames{i};

    classFolder=[root slash className];

    if ~isfolder(classFolder)
        mkdir(classFolder);
    end
    
end

addpath(genpath(root));