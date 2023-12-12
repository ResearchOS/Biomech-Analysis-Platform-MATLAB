function [bool] = isInTrial(subName, trialName, uuid)

%% PURPOSE: RETURN BOOLEAN INDICATING IF THE PROVIDED VR UUID EXISTS IN THE SPECIFIED TRIAL OR NOT.

bool = false;

if ~isUUID(uuid)
    return;
end

abstractID = getAbstractID(uuid);

dataPath = getCurrent('Data_Path');

path = [dataPath filesep 'MAT Data Files' filesep subName filesep trialName filesep abstractID filesep uuid '.mat'];

if isfile(path)
    bool = true;
end