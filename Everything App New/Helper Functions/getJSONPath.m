function [fullPath] = getJSONPath(uuid)

%% PURPOSE: GET THE FULL FILE PATH FOR THE JSON FILE WITH THE CORRESPONDING UUID

if isempty(uuid)
    fullPath = '';
    return;
end

slash = filesep;
commonPath = getCommonPath();

if isstruct(uuid)
    uuid = uuid.UUID;
end

[abbrev, abstractID, instanceID] = deText(uuid);

class = className2Abbrev(abbrev, true);

if isempty(instanceID)
    uuid = genUUID(class, abstractID); % In case uuid is provided with .json extension
    fullPath = [commonPath slash class slash uuid '.json'];
else
    uuid = genUUID(class, abstractID, instanceID); % In case uuid is provided with .json extension
    fullPath = [commonPath slash class slash 'Instances' slash uuid '.json'];
end