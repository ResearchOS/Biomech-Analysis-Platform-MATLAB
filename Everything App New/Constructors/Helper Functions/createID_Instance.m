function [instanceID]=createID_Instance(abstractID, class)

%% PURPOSE: CREATE INSTANCE ID FOR THE SPECIFIED OBJECT.

idLength = 3; % Number of characters in instanceID

slash=filesep;

commonPath=getCommonPath();
classFolder=[commonPath slash class slash 'Instances'];

files=dir(classFolder);
fileNames={files.name};
isDir=[files.isdir];
fileNames=fileNames(~isDir); % Remove folders from the list.

isNewID=false;
maxNum = (16^idLength) - 1;
while ~isNewID
    newID=randi(maxNum,1);
    newID = dec2hex(newID);

    numDigits = length(newID);
    instanceID = [repmat('0',1,idLength-numDigits) newID];

    uuid = genUUID(class, abstractID, instanceID);

    if ~any(contains(fileNames,uuid))
        isNewID = true;
    end

end