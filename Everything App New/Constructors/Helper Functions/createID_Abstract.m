function [id]=createID_Abstract(class)

%% PURPOSE: CREATE AN ID NUMBER FOR THE CURRENTLY SPECIFIED CLASS

idLength = 6; % Number of characters in abstract ID

slash=filesep;

commonPath=getCommonPath();
classFolder=[commonPath slash class];

files=dir(classFolder);
fileNames={files.name};
isDir=[files.isdir];
fileNames=fileNames(~isDir); % Remove folders from the list.

isNewID=false;
maxNum = (16^idLength) - 1;
while ~isNewID
    newID=randi(maxNum,1);
    newID = dec2hex(newID); % Convert the randomly generated number to hexadecimal char
    
    numDigits=length(newID);
    id=[repmat('0',1,idLength-numDigits) newID]; % Ensure that the hex code is 6 digits long

    if ~any(contains(fileNames,id))
        isNewID=true;
    end
end