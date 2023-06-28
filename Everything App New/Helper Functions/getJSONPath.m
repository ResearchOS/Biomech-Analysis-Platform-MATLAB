function [fullPath] = getJSONPath(uuid)

%% PURPOSE: GET THE FULL FILE PATH FOR THE JSON FILE WITH THE CORRESPONDING UUID

slash = filesep;
commonPath = getCommonPath();

[abbrev, abstractID, instanceID] = deText(uuid);
class = className2Abbrev(abbrev, true);

if isempty(instanceID)
    fullPath = [commonPath slash class slash uuid '.json'];
else
    fullPath = [commonPath slash class slash 'Instances' slash uuid '.json'];
end