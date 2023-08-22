function [Data]=loadMAT(dataPath, uuid, subName, trialName)

%% PURPOSE: LOAD DATA FROM A MAT FILE.

slash=filesep;

matFolder=[dataPath slash 'MAT Data Files'];

if ~exist('subName','var')==1
    matFolder=[matFolder slash 'Project'];    
else
    matFolder=[matFolder slash subName];

    if exist('trialName','var')==1
        matFolder=[matFolder slash trialName];
    else
        matFolder=[matFolder slash 'Subject'];
    end
end

[type, abstractID, instanceID] = deText(uuid);
abstractUUID = genUUID(type, abstractID);
matFolder=[matFolder slash abstractUUID];

filePath=[matFolder slash uuid '.mat'];

load(filePath,'Data');