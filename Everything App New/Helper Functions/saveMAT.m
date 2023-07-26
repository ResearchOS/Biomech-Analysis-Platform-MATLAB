function []=saveMAT(dataPath, Metadata2, uuid, Data, subName, trialName)

%% PURPOSE: SAVE DATA TO MAT FILE.

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

Metadata.Metadata=Metadata2;
Metadata.Data=Data;

try
    save(filePath,'-struct','Metadata','-v6');
catch
    mkdir(matFolder);
    save(filePath,'-struct','Metadata','-v6');
end