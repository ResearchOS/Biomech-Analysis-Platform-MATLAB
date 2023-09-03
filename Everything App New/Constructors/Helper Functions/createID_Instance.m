function [instanceID]=createID_Instance(abstractID, class, uuids)

%% PURPOSE: CREATE INSTANCE ID FOR THE SPECIFIED OBJECT.
global conn;
idLength = 3; % Number of characters in instanceID

if nargin==2
    tablename = getTableName(class);
    sqlquery = ['SELECT UUID FROM ' tablename];
    uuids = fetch(conn, sqlquery);
    uuids = uuids.UUID;
end

isNewID=false;
maxNum = (16^idLength) - 1;
s = rng; % Capture the current RNG settings.
rng('shuffle');
while ~isNewID
    newID=randi(maxNum,1);
    newID = dec2hex(newID);

    numDigits = length(newID);
    instanceID = [repmat('0',1,idLength-numDigits) newID];

    uuid = genUUID(class, abstractID, instanceID);

    if ~any(ismember(uuids,uuid))
        isNewID = true;
    end

end

rng(s); % Restore the RNG settings.