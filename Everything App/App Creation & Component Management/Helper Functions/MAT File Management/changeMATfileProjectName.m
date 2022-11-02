function []=changeMATfileProjectName(matDataFilesPath,newProjectName)

%% PURPOSE: AFTER COPYING AN EXISTING PROJECT'S DATA OVER TO A NEW PROJECT'S DATA PATH, RENAME THE PROJECTNAME TO MATCH THE NEW PROJECT
slash=filesep;
if ~isequal(matDataFilesPath(end),slash)
    matDataFilesPath=[matDataFilesPath slash];
end

listing=dir(matDataFilesPath);

dirIdx=[listing.isdir];
subNames={listing.name};

subNames=subNames(dirIdx);
subNames=subNames(~contains(subNames,'.'));

for sub=1:length(subNames)
    subName=subNames{sub};

    currSubPath=[matDataFilesPath subName];

    listing=dir(currSubPath);

    dirIdx=[listing.isdir];
    trialNames={listing.name};
    trialNames=trialNames(~dirIdx);

    for trialNum=1:length(trialNames)
        trialName=trialNames{trialNum};
        prevFilePath=[currSubPath slash trialName];
        [~,~,ext]=fileparts(trialName);
        trialName=trialName(1:end-length(ext));
        underscoreIdx=strfind(trialName,'_');

        trialName=[trialName(1:underscoreIdx(end)) newProjectName ext];

        newFilePath=[currSubPath slash trialName];
        movefile(prevFilePath,newFilePath);

    end


end