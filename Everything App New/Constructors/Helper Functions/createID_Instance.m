function [instanceID]=createID_Instance(abstractID, class)

%% PURPOSE: CREATE INSTANCE ID FOR THE SPECIFIED OBJECT.

slash=filesep;

commonPath=getCommonPath();
classFolder=[commonPath slash class slash 'Instances'];

isNewID=false;
while ~isNewID
    newID=randi(4095,1); % Max 3 digits

    newID=dec2hex(newID); % Convert the randomly generated number to hexadecimal char
    numDigits=length(newID);
    instanceID=[repmat('0',1,3-numDigits) newID]; % Ensure that the hex code is 6 digits long

    %% NEED TO CHANGE THIS TO CHECK THIS OBJECT TYPE'S COMMON FOLDER!
    listing = dir(classFolder);
    filenames = {listing.name};

    uuid = genUUID(class, abstractID, instanceID);    
    if ~ismember(uuid, filenames)
        isNewID=true;
    end

end