function []=moveToArchive(uuid)

%% PURPOSE: MOVE A JSON FILE TO ITS ARCHIVE FOLDER. IF IT'S AN ABSTRACT JSON, ALSO MOVE ALL OF ITS INSTANCES.

[type, abstractID, instanceID] = deText(uuid);

initPath = getJSONPath(uuid);
[folder, name, ext] = fileparts(initPath);

slash = filesep;
archiveFolder = [folder slash 'Archive'];

archivePath = [archiveFolder slash name ext];

movefile(initPath, archivePath); % Move the abstract or instance file to the archive.
if ~isempty(instanceID)     
    return; % Done after moving the instance file to the archive.
end

%% Move all instances for an abstract file.
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