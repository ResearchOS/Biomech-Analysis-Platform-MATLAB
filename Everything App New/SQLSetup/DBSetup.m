function [conn]=DBSetup(dbFile)

%% PURPOSE: SET UP THE DATABASE AND THE TABLES

%% Create or set up the database.
mode = 'connect';
if exist(dbFile,'file')~=2
    mode = 'create';
end

conn = sqlite(dbFile, mode);

%% Ensure the existence of the object tables
tableNames = sqlfind(conn,'');
% "Logsheets_Instances"
% "Projects_Instances"
% "SpecifyTrials_Instances"
% "Variables_Instances"
% "Analyses_Instances"
% "ProcessGroups_Instances"
% "Analyses_Abstract"
% "Logsheets_Abstract"
% "Process_Instances"
% "ProcessGroups_Abstract"
% "Projects_Abstract"
% "SpecifyTrials_Abstract"
% "Variables_Abstract"
% "Process_Abstract"
% "PJ_AN"
% "AN_PR"
% "AN_PG"
% "PG_PR"
% "PG_PG"
% "PR_VR"
% "VR_PR"
% "PJ_LG"
% Settings

sqlquery = cell();
tmp = '';
if ~ismember(tableNames,'Projects_Abstract')
    tmp = strcat(['CREATE TABLE Projects_Abstract (',...
    'UUID               TEXT    PRIMARY KEY',...
                               'NOT NULL',...
                               'UNIQUE,',...
    '[Date Created]     TEXT    NOT NULL,',...
    '[Date Modified]    TEXT    NOT NULL,',...
    'Name               REAL    NOT NULL',...
                               'DEFAULT [Default],',...
    '[Created By]       TEXT    NOT NULL,',...
    '[Last Modified By] TEXT    NOT NULL,',...
    'Description        TEXT    NOT NULL,',...
    '[Out Of Date]      INTEGER NOT NULL',...
                               'DEFAULT (true)',...
')']);
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'Analyses_Abstract')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'ProcessGroups_Abstract')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'Process_Abstract')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'Variables_Abstract')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'Logsheets_Abstract')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'SpecifyTrials_Abstract')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'Projects_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'Analyses_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'ProcessGroups_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'Process_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'Variables_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'Logsheets_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'SpecifyTrials_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'PJ_AN')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'AN_PR')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'AN_PG')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'PG_PR')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'PG_PG')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'PR_VR')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'VR_PR')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'PJ_LG')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'Settings')
    sqlquery = [sqlquery; {tmp}];
end