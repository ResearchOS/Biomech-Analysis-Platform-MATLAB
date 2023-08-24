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
if isempty(tableNames)
    tableNames = {};
end
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

%% Object tables
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
createInst = ['CREATE TABLE XXX_Instances (UUID TEXT NOT NULL UNIQUE,',...
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
date = char(datetime('now'));
defaultAbsInit = ['INSERT INTO XXX_Abstract (UUID, Date_Created, Date_Modified, Name, Created_By, Last_Modified_By, Description, OutOfDate)',...
    'VALUES (''ZZZZZZ'', ''' date ''', ''' date ''', ''INIT'', ''INIT'', ''INIT'', ''INIT'', 0);'];
defaultInstInit = ['INSERT INTO XXX_Instances (UUID, Date_Created, Date_Modified, Name, Created_By, Last_Modified_By, Description, OutOfDate, Abstract_UUID)',...
    'VALUES (''ZZZZZZ_ZZZ'', ''' date ''', ''' date ''', ''INIT'', ''INIT'', ''INIT'', ''INIT'', 0, ''ZZZZZZ'');'];

objTableNames = {'Projects','Analyses','ProcessGroups','Process','Variables','Logsheets','SpecifyTrials'};
modifiedNames = {};
for i=1:length(objTableNames)
    tableName = objTableNames{i};

    % Initialize abstract object tables
    if ~any(contains(tableNames,tableName) & contains(tableNames,'Abstract'))
        createAbsCurr = strrep(createAbs, 'XXX', tableName);
        execute(conn, createAbsCurr);
        defaultAbsInitCurr = strrep(defaultAbsInit, 'XXX', tableName);
        execute(conn, defaultAbsInitCurr);
        modifiedNames = [modifiedNames; {[tableName '_Abstract']}];
    end

    % Initialize instance object tables
    if ~any(contains(tableNames,tableName) & contains(tableNames,'Instance'))
        createInstCurr = strrep(createInst, 'XXX', tableName);
        execute(conn, createInstCurr);
        defaultInstInitCurr = strrep(defaultInstInit, 'XXX', tableName);
        execute(conn, defaultInstInitCurr);
        modifiedNames = [modifiedNames; {[tableName '_Instances']}];
    end
end

% Add custom columns to each table.
% Projects_Instances
if ismember('Projects_Instances',modifiedNames)
    sqlquery = ['ALTER TABLE Projects_Instances ADD Data_Path TEXT'];
    execute(conn, sqlquery);    
    sqlquery = ['ALTER TABLE Projects_Instances ADD Project_Path TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Projects_Instances ADD Process_Queue TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Projects_Instances ADD Current_Analysis TEXT REFERENCES Analyses_Instances(UUID) ON DELETE RESTRICT ON UPDATE CASCADE'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Projects_Instances ADD Current_Logsheet TEXT REFERENCES Logsheets_Instances(UUID) ON DELETE RESTRICT ON UPDATE CASCADE'];
    execute(conn, sqlquery);  
    sqlquery = ['INSERT INTO TABLE Projects_Instances (Data_Path, Project_Path, Process_Queue, Current_Logsheet, Current_Analysis) VALUES (''NULL'', ''NULL'', ''NULL'', ''ZZZZZZ_ZZZ'', ''ZZZZZZ_ZZZ'');'];
    execute(conn, sqlquery);
end

if ismember('Process_Abstract',modifiedNames)
    sqlquery = ['ALTER TABLE Process_Abstract ADD NamesInCode TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Process_Abstract ADD Level TEXT DEFAULT [''T'']'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Process_Abstract ADD ExecFileName TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['INSERT INTO TABLE Process_Abstract (NamesInCode, ExecFileName) VALUES (''NULL'', ''NULL'');'];
    execute(conn, sqlquery);
end

if ismember('Process_Instances',modifiedNames)
    sqlquery = ['ALTER TABLE Process_Instances ADD SpecifyTrials TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Process_Instances ADD Date_Last_Ran TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['INSERT INTO TABLE Process_Instances (SpecifyTrials, Date_Last_Ran) VALUES (''NULL'',''NULL'');'];
    execute(conn, sqlquery);
end

if ismember('Variables_Abstract',modifiedNames)
    sqlquery = ['ALTER TABLE Variables_Abstract ADD IsHardCoded INTEGER DEFAULT (false)'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Variables_Abstract ADD Level TEXT DEFAULT [''T'']'];
    execute(conn, sqlquery);
end

if ismember('Variables_Instances',modifiedNames)
    sqlquery = ['ALTER TABLE Variables_Instances ADD HardCodedValue TEXT DEFAULT [''NULL'']'];
    execute(conn, sqlquery);
end

if ismember('SpecifyTrials_Abstract',modifiedNames)
    sqlquery = ['ALTER TABLE SpecifyTrials_Abstract ADD Logsheet_Parameters TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE SpecifyTrials_Abstract ADD Data_Parameters TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['INSERT INTO TABLE SpecifyTrials_Abstract (Logsheet_Parameters, Data_Parameters) VALUES (''NULL'', ''NULL'');'];
    execute(conn, sqlquery);
end

if ismember('Logsheets_Abstract',modifiedNames)
    sqlquery = ['ALTER TABLE Logsheets_Abstract ADD Logsheet_Path TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Logsheets_Abstract ADD Num_Header_Rows INTEGER DEFAULT -1'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Logsheets_Abstract ADD Subject_Codename_Header TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Logsheets_Abstract ADD Target_TrialID_Header TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Logsheets_Abstract ADD LogsheetVar_Params TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['INSERT INTO TABLE Logsheets_Abstract (Logsheet_Path, Subject_Codename_Header, Target_TrialID_Header, LogsheetVar_Params)',...
        ' VALUES (''NULL'', ''NULL'', ''NULL'', ''NULL'', ''NULL'');'];
    execute(conn, sqlquery);
end

if ismember('Analyses_Instances',modifiedNames)
    sqlquery = ['ALTER TABLE Analyses_Instances ADD Tags TEXT'];
    execute(conn, sqlquery);
    sqlquery = ['INSERT INTO TABLE Analyses_Instances (Tags) VALUES (''NULL'');'];
    execute(conn, sqlquery);
end


%% JOIN TABLES
createJoinTable = ['CREATE TABLE XXX_YYY (',...
    'AAA_ID TEXT REFERENCES CCC_Instances (UUID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,',...
    'BBB_ID TEXT REFERENCES DDD_Instances (UUID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,',...
    'PRIMARY KEY (AAA_ID, BBB_ID)',...
    ');'];

objAbbrevs = {{'PJ','AN'},{'AN','PR'},{'AN','PG'},{'PG','PR'},{'PG','PG'},{'PR','VR'},{'VR','PR'},{'PJ','LG'}};
modifiedNames = {};
for i=1:length(objAbbrevs)
    abbrevs = objAbbrevs{i};
    name = [abbrevs{1} '_' abbrevs{2}];
    if ismember(name,tableNames)
        continue;
    end

    modifiedNames = [modifiedNames; {name}];

    if isequal(abbrevs{1},abbrevs{2})
        newAbbrevs{1} = ['Parent_' abbrevs{1}];
        newAbbrevs{2} = ['Child_' abbrevs{2}];
    else
        newAbbrevs = abbrevs;
    end

    class1 = className2Abbrev(abbrevs{1}, true);
    class2 = className2Abbrev(abbrevs{2}, true);
    if ~isequal(class1(end),'s')
        class1 = [class1 's'];
    end
    if isequal(abbrevs{1},'AN')
        class1(end-1) = 'e'; % Analyses
    end
    if ~isequal(class2(end),'s')
        class2 = [class2 's'];
    end
    if isequal(abbrevs{2},'AN')
        class2(end-1) = 'e'; % Analyses
    end    

    createJoinTableCurr = strrep(createJoinTable,'XXX',abbrevs{1});
    createJoinTableCurr = strrep(createJoinTableCurr,'YYY',abbrevs{2});
    createJoinTableCurr = strrep(createJoinTableCurr,'AAA',newAbbrevs{1});
    createJoinTableCurr = strrep(createJoinTableCurr,'BBB',newAbbrevs{2});
    createJoinTableCurr = strrep(createJoinTableCurr,'CCC',class1);
    createJoinTableCurr = strrep(createJoinTableCurr,'DDD',class2);

    execute(conn, createJoinTableCurr);

end

% Custom Join table columns
if ismember('VR_PR',modifiedNames)
    sqlquery = ['ALTER TABLE VR_PR ADD NameInCode TEXT'];
    execute(conn, sqlquery);
end

if ismember('PR_VR',modifiedNames)
    sqlquery = ['ALTER TABLE PR_VR ADD NameInCode TEXT'];
    execute(conn, sqlquery);
end

%% Settings table
% Put values into the table.
if ~ismember('Settings',tableNames)
    sqlquery = ['CREATE TABLE Settings (VariableName TEXT PRIMARY KEY NOT NULL UNIQUE,',...
        'VariableValue NOT NULL);'];    
    execute(conn, sqlquery);

    % Initialize the settings in the table.
    VariableName = {'commonPath', 'Computer_ID', 'Current_Project_Name','Current_Tab_Title'}';
    VariableValue = {'NULL','NULL','NULL','NULL'}';
    t = table(VariableName, VariableValue);
    sqlwrite(conn, 'Settings', t);

    %% Now that the table has been initialized, put the proper values in it.
    % Computer ID
    computerID = getComputerID(); % Also sets the Computer ID

    % DB file path (previously known as common path)
    commonPath.(computerID) = dbFile;
    sqlquery = ['UPDATE Settings SET VariableValue = ''' jsonencode(commonPath) ''' WHERE VariableName = ''commonPath'''];
    execute(conn, sqlquery);    

    % Current_Tab_Title
    Current_Tab_Title = 'Projects';
    sqlquery = ['UPDATE Settings SET VariableValue = ''' Current_Tab_Title ''' WHERE VariableName = ''Current_Tab_Title'''];
    execute(conn, sqlquery);

    % Current_Project_Name

    % Try to get the second row of the Projects_Instances table. If there's
    % only one row (the initialization row), then create a new row, and set
    % the current project as its UUID.
    sqlquery = 'SELECT COUNT(UUID) FROM Projects_Instances;';
    numRows = fetch(conn, sqlquery);
    numRows = double(numRows.("COUNT(UUID)"));
    if numRows == 1
        projStruct = createNewObject(true, 'Project', 'Default','','', true);
        uuid = projStruct.UUID;
    else % Projects instances already exists, but the Settings table is being rebuilt for some reason.
        sqlquery = 'SELECT Date_Modified FROM Projects_Instances';
        dates = sqlread(conn, sqlquery);
        dates = datetime(dates);
        date = char(max(dates));
        sqlquery = ['SELECT UUID FROM Projects_Instances WHERE Date_Modified = ''' date ''''];
        uuid = sqlread(conn, sqlquery);
    end

    sqlquery = ['UPDATE Settings SET VariableValue = ''' uuid ''' WHERE VariableName = ''Current_Project_Name'''];
    execute(conn, sqlquery);
end