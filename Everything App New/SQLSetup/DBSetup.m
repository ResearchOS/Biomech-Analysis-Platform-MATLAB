function []=DBSetup(dbFile)

%% PURPOSE: SET UP THE DATABASE AND THE TABLES
global conn

%% Create or set up the database.
mode = 'connect';
if exist(dbFile,'file')~=2
    mode = 'create';
end

conn = sqlite(dbFile, mode);

%% Ensure the existence of the object tables
tableNames = sqlfind(conn,'');
tableNames = tableNames.Table;
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

% Create the abstract & instance tables.
createAbs = strcat(['CREATE TABLE XXX_Abstract (UUID TEXT PRIMARY KEY NOT NULL UNIQUE,',...
    'Date_Created     TEXT    NOT NULL,',...
    'Date_Modified    TEXT    NOT NULL,',...
    'Name             TEXT    NOT NULL DEFAULT [Default],',...
    'Created_By       TEXT    NOT NULL,',...
    'Last_Modified_By TEXT    NOT NULL,',...
    'Description      TEXT    NOT NULL,',...
    'OutOfDate        INTEGER NOT NULL DEFAULT (true)',...
    ');']); 
createInst = ['CREATE TABLE XXX_Instance (UUID TEXT NOT NULL UNIQUE,',...
    'Date_Created     TEXT    NOT NULL,',...
    'Created_By       TEXT    NOT NULL,',...
    'Abstract_UUID    TEXT    REFERENCES XXX_Abstract (UUID) NOT NULL,',...
    'Name             TEXT    NOT NULL DEFAULT [Default],',...
    'Date_Modified    TEXT    NOT NULL,',...
    'Last_Modified_By TEXT    NOT NULL,',...
    'Description      TEXT    NOT NULL,',...
    'OutOfDate        INTEGER NOT NULL DEFAULT (true),',...
    'PRIMARY KEY (UUID, Abstract_UUID));'];

% Create a first row that means nothing because MATLAB can't have a NULL
% value in the first row.
defaultAbsInit = ['INSERT INTO XXX (UUID, Date_Created, Date_Modified, Name, Created_By, Last_Modified_By, Description, OutOfDate)',...
    'VALUES (''ZZZZZZ'', ''INIT'', ''INIT'', ''INIT'', ''INIT'', ''INIT'', ''INIT'', ''INIT'');'];
defaultInstInit = ['INSERT INTO XXX (UUID, Date_Created, Date_Modified, Name, Created_By, Last_Modified_By, Description, OutOfDate, Abstract_UUID)',...
    'VALUES (ZZZZZZ_ZZZ, ''INIT'', ''INIT'', ''INIT'', ''INIT'', ''INIT'', ''INIT'', ''INIT'', ''INIT'', ''ZZZZZZ'');'];

%% Abstract tables
tableName = 'Projects';
objTableNames = {'Projects','Analyses','ProcessGroups','Process','Variables','Logsheets','SpecifyTrials'};
for i=1:length(objTableNames)
    tableName = objTableNames{i};

    % Initialize abstract object tables
    if ~any(contains(tableNames,tableName) & contains(tableNames,'Abstract'))
        createAbsCurr = strrep(createAbs, 'XXX', tableName);
        exec(conn, createAbsCurr);
        defaultAbsInitCurr = strrep(defaultAbsInit, 'XXX', tableName);
        exec(conn, defaultAbsInitCurr);
    end

    % Initialize instance object tables
    if ~any(contains(tableNames,tableName) & contains(tableNames,'Abstract'))
        createInstCurr = strrep(createInst, 'XXX', tableName);
        exec(conn, createInstCurr);
        defaultInstInitCurr = strrep(defaultInstInit, 'XXX', tableName);
        exec(conn, defaultInstInitCurr);
    end

    
if ~ismember(tableName, tableNames)
    createAbsCurr = strrep(createAbs, 'XXX', tableName);
    exec(conn, createAbsCurr);
    defaultAbsInitCurr = strrep(defaultAbsInit, 'XXX', tableName);
    exec(conn, defaultAbsInitCurr);

    createInstCurr = strrep(createInst, 'XXX', tableName);
    exec(conn, createInstCurr);
    defaultInstInitCurr = strrep(defaultInstInit, 'XXX', tableName);
    exec(conn, defaultInstInitCurr);
end

tableName = 'Analyses';
if ~ismember(tableName, tableNames)
    createAbsCurr = strrep(createAbs, 'XXX', tableName);
    exec(conn, createAbsCurr);
    defaultAbsInitCurr = strrep(defaultAbsInit, 'XXX', tableName);
    exec(conn, defaultAbsInitCurr);
end

tableName = 'ProcessGroups';
if ~ismember(tableName, tableNames)
    createAbsCurr = strrep(createAbs, 'XXX', tableName);
    exec(conn, createAbsCurr);
    defaultAbsInitCurr = strrep(defaultAbsInit, 'XXX', tableName);
    exec(conn, defaultAbsInitCurr);
end

tableName = 'Process';
if ~ismember(tableName, tableNames)
    createAbsCurr = strrep(createAbs, 'XXX', tableName);
    exec(conn, createAbsCurr);
    defaultAbsInitCurr = strrep(defaultAbsInit, 'XXX', tableName);
    exec(conn, defaultAbsInitCurr);
end

tableName = 'Variables';
if ~ismember(tableName, tableNames)
    createAbsCurr = strrep(createAbs, 'XXX', tableName);
    exec(conn, createAbsCurr);
    defaultAbsInitCurr = strrep(defaultAbsInit, 'XXX', tableName);
    exec(conn, defaultAbsInitCurr);
end

tableName = 'Logsheets';
if ~ismember(tableName, tableNames)
    createAbsCurr = strrep(createAbs, 'XXX', tableName);
    exec(conn, createAbsCurr);
    defaultAbsInitCurr = strrep(defaultAbsInit, 'XXX', tableName);
    exec(conn, defaultAbsInitCurr);
end

tableName = 'SpecifyTrials';
if ~ismember(tableName, tableNames)
    createAbsCurr = strrep(createAbs, 'XXX', tableName);
    exec(conn, createAbsCurr);
    defaultAbsInitCurr = strrep(defaultAbsInit, 'XXX', tableName);
    exec(conn, defaultAbsInitCurr);
end

%% Instances
tableName = 'Projects';
if ~ismember(tableName,)
    createAbsCurr = strrep(createAbs, 'XXX', tableName);
    exec(conn, createAbsCurr);
    defaultAbsInitCurr = strrep(defaultAbsInit, 'XXX', tableName);
    exec(conn, defaultAbsInitCurr);
end

if ~ismember(tableName,'Analyses_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableNames,'ProcessGroups_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableName,'Process_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableName,'Variables_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableName,'Logsheets_Instances')
    sqlquery = [sqlquery; {tmp}];
end

if ~ismember(tableName,'SpecifyTrials_Instances')
    sqlquery = [sqlquery; {tmp}];
end


%% JOIN TABLES
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

% Put values into the table.
if ~ismember(tableNames,'Settings')
    VariableName = {'commonPath', 'Computer_ID', 'Current_Project_Name',...
    'Current_Tab_Title'}';
    VariableValue = {'NULL','NULL','NULL','NULL'}';
    t = table(VariableName, VariableValue);
    % sqlquery = ['INSERT INTO Settings (VariableName, VariableValue) VALUES ',...
    %     '(''' VariableName{1} ''',' Values{1} '), ',...
    %     '(''' VariableName{2} ''',' Values{2} '), ',...
    %     '(''' VariableName{3} ''',' Values{3} '), ',...
    %     '(''' VariableName{4} ''',' Values{4} ') ',...
    %     ];
    % exec(conn, sqlquery);
    sqlwrite(conn, 'Settings', t);
end