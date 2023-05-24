function []=saveMAT(dataPath, Metadata2, psText, Data, subName, trialName)

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

piText=getPITextFromPS(psText);
matFolder=[matFolder slash piText];

filePath=[matFolder slash psText '.mat'];

Metadata.Metadata=Metadata2;
Metadata.Data=Data;

try
    save(filePath,'-struct','Metadata','-v6');
catch
    mkdir(matFolder);
    save(filePath,'-struct','Metadata','-v6');
end