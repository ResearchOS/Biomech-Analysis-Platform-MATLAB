function []=archiveButtonPushed(src,event)

%% PURPOSE: CREATE A DATED ARCHIVE OF THE CURRENT PROJECT'S CODE, AND DATA TOO IF THE CHECKBOX IS CHECKED.
tic;
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectName=getappdata(fig,'projectName');

codePath=getappdata(fig,'codePath');
dataPath=getappdata(fig,'dataPath');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
[~,projectSettingsMATName]=fileparts(projectSettingsMATPath); % Get just the file name.
projectSettingsMATName=[projectSettingsMATName '.mat']; % Add extension

slash=filesep;

allArchivesFolderName=[codePath 'Project Archives'];

if exist(allArchivesFolderName,'dir')~=7
    mkdir(allArchivesFolderName);
end

currDate=char(datetime('now','TimeZone','America/New_York')); % All times in New York timezone
currDate=currDate(1:end-3); % Remove the seconds
currDate=[currDate(1:end-3) currDate(end-1:end)]; % Remove the colon from the time, leaving strictly military time in US date format
currDate(isspace(currDate))='_';
currDate=strrep(currDate,'-','_');

currArchiveFolderName=[allArchivesFolderName slash 'Archive_' projectName '_' currDate '_ET'];

if exist(currArchiveFolderName,'dir')~=7
    mkdir(currArchiveFolderName);
end

folderNames={'Hard-Coded Variables','SpecifyTrials','Processing Functions'};
matFileNames={projectSettingsMATName};

%% Copy the folders to the archive folder.
for i=1:length(folderNames)
    currFolderLoc=[codePath folderNames{i}];
    archiveFolderLoc=[currArchiveFolderName slash folderNames{i}];
    copyfile(currFolderLoc,archiveFolderLoc);
end

%% Copy the .mat settings files to the archive folder
for i=1:length(matFileNames)
    currFileLoc=[codePath matFileNames{i}];
    archiveFileLoc=[currArchiveFolderName slash matFileNames{i}];
    copyfile(currFileLoc,archiveFileLoc);
end

%% Copy the logsheet to the archive folder
logsheetPath=getappdata(fig,'logsheetPath');
logsheetPathMAT=getappdata(fig,'logsheetPathMAT');
[~,logsheetPathName,ext]=fileparts(logsheetPath);
[~,logsheetPathMATName]=fileparts(logsheetPathMAT);

copyfile(logsheetPath,[currArchiveFolderName slash logsheetPathName ext]);
copyfile(logsheetPathMAT,[currArchiveFolderName slash logsheetPathMATName '.mat']);

%% Create run code
% Write the 'runCodeFunc.m' file to the archive folder
runCodeFilePath=[currArchiveFolderName slash 'RunCode_' projectName '_' currDate '.m'];
createRunCode(fig,runCodeFilePath,currArchiveFolderName,codePath);

%% Copy the entirety of the PGUI folder to the archive folder
% everythingPath=getappdata(fig,'everythingPath');
% copyfile(everythingPath,[currArchiveFolderName slash 'PGUI']);

%% Check if archiving data as well as the code.
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');
% load(projectSettingsMATPath,'NonFcnSettingsStruct');

archiveData=NonFcnSettingsStruct.Projects.ArchiveData;
if archiveData==0
    %% If not archiving data, compress and end here.
    zip(currArchiveFolderName,currArchiveFolderName);
    rmdir(currArchiveFolderName,'s');
else
    %% Copy the data over.
    matDataFilesFolder=[dataPath 'MAT Data Files'];
    matDataFilesArchiveFolder=[currArchiveFolderName slash 'MAT Data Files'];

    rawDataFilesFolder=[dataPath 'Raw Data Files'];
    rawDataFilesArchiveFolder=[currArchiveFolderName slash 'Raw Data Files'];

    copyfile(rawDataFilesFolder,rawDataFilesArchiveFolder); % No compression on the raw data because they're likely small enough!

    zip(matDataFilesArchiveFolder,matDataFilesFolder);
    zip(currArchiveFolderName,currArchiveFolderName);
    rmdir(currArchiveFolderName,'s');

end

disp(['Completed archive in ' num2str(toc) ' seconds!']);
disp(['Saved to: ' currArchiveFolderName]);

if ismac==1
    path=allArchivesFolderName;
    spaceSplit=strsplit(path,' ');

    newPath='';
    for i=1:length(spaceSplit)
        if i>1
            mid='\ ';
        else
            mid='';
        end
        newPath=[newPath mid spaceSplit{i}];
    end

    system(['open ' newPath slash]);
elseif ispc==1
    winopen(allArchivesFolderName);
end