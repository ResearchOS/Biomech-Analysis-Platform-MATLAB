function []=saveMAT(dataPath, desc, psText, Data, subName, trialName)

%% PURPOSE: SAVE DATA TO MAT FILE.

slash=filesep;

if exist(dataPath,'dir')~=7
    error('Invalid data path!');    
end

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

currDate=datetime('now');

filePath=[matFolder slash psText '.mat'];

varNames={'Data'};

% if exist(filePath,'file')~=2   
%     DateCreated=currDate;        
%     varNames={'DateCreated'};
% end

DateModified=currDate;
Description=desc;

varNames=[varNames, {'DateModified'}, {'Description'}];

% How to avoid overwriting "DateCreated" but not have to load the file to
% obtain that info? To be realistic, "DateCreated" is not *that* important.
% "DateModified" is much more important.
try
    save(filePath,varNames{:},'-v6');
catch
    mkdir(matFolder);
    save(filePath,varNames{:},'-v6');
end