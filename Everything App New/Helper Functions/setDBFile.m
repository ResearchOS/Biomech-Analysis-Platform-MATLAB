function []=setDBFile(dbFile)

%% PURPOSE: PROMPT THE USER FOR THE SETTINGS PATH

clearAllMemoizedCaches;

if nargin==0
    dbFile=uigetdir(cd,'Select Path to Save DB File');
end

if dbFile==0
    return; % No change to the database path.
    % commonPath=userpath; % If no common path is selected, it will just default to the MATLAB default userpath.
end

dbFilePrev = getDBFile();

setCurrent(dbFile, 'dbFile');
% 
% sqlquery = ['UPDATE Settings SET VariableValue = ''' dbFile ''' WHERE VariableName = ''dbFile'''];
% execute(conn, sqlquery);

% Move the database to the new location.
if exist(dbFilePrev,'file')==2 && exist(dbFile,'file')==2
    movefile(dbFilePrev,dbFile);
end