function [Data]=loadMAT(dataPath, psText, subName, trialName)

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

piText=getPITextFromPS(psText);
matFolder=[matFolder slash piText];

filePath=[matFolder slash psText '.mat'];

load(filePath,'Data');