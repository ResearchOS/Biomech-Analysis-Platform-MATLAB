function [dbFile]=getDBFile()

%% PURPOSE: RETURN THE PATH TO THE DIRECTORY WHERE THE PGUI SETTINGS FILES ARE STORED.

h = @memoizedGetDBFile;
memFcn = memoize(h);

dbFile = memFcn();

end

function [dbFile] = memoizedGetDBFile()
global conn;
sqlquery = ['SELECT VariableValue FROM Settings WHERE VariableName = ''dbFile'''];
var = fetch(conn, sqlquery);
dbFile = jsondecode(var.VariableValue);
computerID = getComputerID();
dbFile = dbFile.(computerID); % Get the current computer's ID

if exist(dbFile,'file')==2
    return;
end

setDBFile();
dbFile = getDBFile();

end