function [id]=createID_Abstract(class)

%% PURPOSE: CREATE AN ID NUMBER FOR THE CURRENTLY SPECIFIED CLASS

slash=filesep;

commonPath=getCommonPath();
classFolder=[commonPath slash class];

files=dir(classFolder);
fileNames={files.name};
isDir=[files.isdir];
fileNames=fileNames(~isDir); % Remove folders from the list.

isNewID=false;
while ~isNewID
    newID=randi(16777215,1); % Max 6 digit hexadecimal value ('FFFFFF')

    if isempty(fileNames) || ~any(contains(fileNames,num2str(newID)))
        isNewID=true;
    end
end

newID=dec2hex(newID); % Convert the randomly generated number to hexadecimal char
numDigits=length(newID);
id=[repmat('0',1,6-numDigits) newID]; % Ensure that the hex code is 6 digits long