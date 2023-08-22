function [uuids]=getInstances(uuid)

%% PURPOSE: RETURN ALL INSTANCES OF AN ABSTRACT OBJECT. IF INSTANCE OBJECT PASSED IN, RETURNS ITSELF.

[type, abstractID, instanceID] = deText(uuid);

% Passed in instance object, returns itself.
if ~isempty(instanceID)
    uuids = '';
    return;
end

% Passed in abstract object, return all instances of that object.
filenames = getClassFilenames(className2Abbrev(type, true), true);
allUUIDs = fileNames2Texts(filenames);

idx = contains(allUUIDs, uuid);
uuids = allUUIDs(idx);