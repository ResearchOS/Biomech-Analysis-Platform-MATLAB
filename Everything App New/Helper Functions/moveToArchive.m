function []=moveToArchive(uuid)

%% PURPOSE: MOVE A JSON FILE TO ITS ARCHIVE FOLDER. IF IT'S AN ABSTRACT JSON, ALSO MOVE ALL OF ITS INSTANCES.

[type, abstractID, instanceID] = deText(uuid);

initPath = getJSONPath(uuid);
[folder, name, ext] = fileparts(initPath);

slash = filesep;
archiveFolder = [folder slash 'Archive'];

archivePath = [archiveFolder slash name ext];

if ~isempty(instanceID)
    movefile(initPath, archivePath);
    return;
end

instPath = [folder slash 'Instances'];
instArchiveFolder = [instPath slash 'Archive'];

listing = dir(instPath);

names = {listing.name};

idx = contains(names, uuid);

names = names(idx);

instUUIDs = fileNames2Texts(names);

for i=1:length(instUUIDs)

    instUUID = instUUIDs{i};    
    initPath = getJSONPath(instUUID);

    instArchivePath = [instArchiveFolder slash instUUID ext];

    movefile(initPath, instArchivePath);

end