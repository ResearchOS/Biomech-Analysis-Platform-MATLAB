function [classNames]=initializeClassFolders()

%% PURPOSE: CREATE THE PROJECT-INDEPENDENT CLASS FOLDERS
root=getCommonPath;

slash=filesep;

classNames={'Variable','Plot','PubTable','StatsTable','Component','Project','Process','Logsheet','ProcessGroup','SpecifyTrials'}; % One folder for each object type

% if nargin==0
%     root=getCommonPath; % Make project-independent folders.
% end

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

    subdir=[classFolder slash 'Implementations'];
    subdirArchive=[subdir slash 'Archive'];

    if ~isfolder(subdir)
        mkdir(subdir);
    end

    if ~isfolder(subdirArchive)
        mkdir(subdirArchive);
    end
    
end

%% Create code folders
codeFolder = [root slash 'Code'];
if ~isfolder(codeFolder)
    mkdir(codeFolder);
end
codeTypes={'Process_Functions','Plots','Components','Stats'};

for i=1:length(codeTypes)
    codeType=codeTypes{i};

    codeTypeFolder = [codeFolder slash codeType];

    if ~isfolder(codeTypeFolder)
        mkdir(codeTypeFolder);
    end

end

addpath(genpath(root));