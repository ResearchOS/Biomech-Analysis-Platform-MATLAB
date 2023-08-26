function [data]=loadJSON(uuid, runCheck)

%% PURPOSE: LOAD A JSON FILE AND RETURN IT DECODED.
% str is either a path or a UUID
global conn;

% if exist('runCheck','var')~=1
%     runCheck = true; % Helpful for testing.
% end

[type, abstractID, instanceID] = deText(uuid);
if ~isempty(instanceID)
    isInstance = true;
else
    isInstance = false;
end
tablename = getTableName(type, isInstance);
sqlquery = ['SELECT * FROM ' tablename ' WHERE UUID = ''' uuid ''';'];
t = fetch(conn, sqlquery);
data = table2MyStruct(t);