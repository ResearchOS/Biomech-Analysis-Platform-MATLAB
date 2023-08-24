function [id]=createID_Abstract(class)

%% PURPOSE: CREATE AN ID NUMBER FOR THE CURRENTLY SPECIFIED CLASS

global conn;
idLength = 6; % Number of characters in abstract ID

tablename = getTableName(class);
sqlquery = ['SELECT UUID FROM ' tablename];
uuids = fetch(conn, sqlquery);
uuids = uuids.UUID;

isNewID=false;
maxNum = (16^idLength) - 1;
s = rng; % Capture the current RNG settings.
rng('shuffle');
while ~isNewID
    newID=randi(maxNum,1);
    newID = dec2hex(newID); % Convert the randomly generated number to hexadecimal char
    
    numDigits=length(newID);
    id=[repmat('0',1,idLength-numDigits) newID]; % Ensure that the hex code is 6 digits long

    if ~any(ismember(uuids,id))
        isNewID=true;
    end
end

rng(s); % Restore the RNG settings.