function []=DBSetup(dbFile, isTest)

%% PURPOSE: SET UP THE DATABASE AND THE TABLES
global conn

%% Create or set up the database.
method = 'default';
% method = 'JDBC';
conn = connectToSQLite(dbFile,method);

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
% "AN_LG"
% "LG_VR"
% "AN_ST"
% Users

%% Create Users table
if ~ismember('Users',tableNames)
    sqlquery = 'CREATE TABLE Users (Username TEXT PRIMARY KEY NOT NULL UNIQUE DEFAULT [NULL]);';
    execute(conn, sqlquery);
    sqlquery = 'INSERT INTO Users (Username) VALUES (''Admin'');';
    execute(conn, sqlquery);
end

%% Object tables
% Create the abstract & instance tables.
% NOTE: ALL COLUMNS MUST HAVE A DEFAULT VALUE THAT IS NOT A NULL VALUE
% BECAUSE MATLAB CANNOT HANDLE NULL VALUES FROM SQLITE USING "SQLITE" COMMAND.
% 'NULL' STRING VALUES ARE USED INSTEAD.
createAbs = strcat(['CREATE TABLE XXX_Abstract (UUID TEXT PRIMARY KEY NOT NULL UNIQUE DEFAULT [ZZZZZZ], ',...
    'Date_Created     TEXT    NOT NULL DEFAULT [NULL], ',...
    'Date_Modified    TEXT    NOT NULL DEFAULT [NULL], ',...
    'Name             TEXT    NOT NULL DEFAULT [Default], ',...
    'Created_By       TEXT    NOT NULL DEFAULT [NULL], ',...
    'Last_Modified_By TEXT    NOT NULL DEFAULT [NULL], ',...
    'Description      TEXT    NOT NULL DEFAULT [NULL], ',...
    'OutOfDate        INTEGER NOT NULL DEFAULT (true)',...
    ');']);
createInst = ['CREATE TABLE XXX_Instances (UUID TEXT PRIMARY KEY NOT NULL UNIQUE DEFAULT [ZZZZZZ_ZZZ], ',...
    'Date_Created     TEXT    NOT NULL DEFAULT [NULL], ',...
    'Created_By       TEXT    NOT NULL DEFAULT [NULL], ',...
    'Abstract_UUID    TEXT    REFERENCES XXX_Abstract (UUID) NOT NULL DEFAULT [ZZZZZZ], ',...
    'Name             TEXT    NOT NULL DEFAULT [Default], ',...
    'Date_Modified    TEXT    NOT NULL DEFAULT [NULL], ',...
    'Last_Modified_By TEXT    NOT NULL DEFAULT [NULL], ',...
    'Description      TEXT    NOT NULL DEFAULT [NULL], ',...
    'OutOfDate        INTEGER NOT NULL DEFAULT (true)',...
    ');'];

allTypes = getTypes();
objTableNames = makeClassPlural(className2Abbrev(allTypes));
modifiedNames = {};
for i=1:length(objTableNames)
    tableName = objTableNames{i};

    % Initialize abstract object tables
    if ~any(contains(tableNames,tableName) & contains(tableNames,'Abstract'))
        createAbsCurr = strrep(createAbs, 'XXX', tableName);
        execute(conn, createAbsCurr);
        modifiedNames = [modifiedNames; {[tableName '_Abstract']}];
    end

    % Initialize instance object tables
    if ~any(contains(tableNames,tableName) & contains(tableNames,'Instance'))
        createInstCurr = strrep(createInst, 'XXX', tableName);
        execute(conn, createInstCurr);
        modifiedNames = [modifiedNames; {[tableName '_Instances']}];
    end
end

%% Add custom columns to each object table.
% Projects_Instances
if ismember('Projects_Instances',modifiedNames)
    sqlquery = ['ALTER TABLE Projects_Instances ADD Data_Path TEXT NOT NULL DEFAULT [NULL]'];
    execute(conn, sqlquery);    
    sqlquery = ['ALTER TABLE Projects_Instances ADD Project_Path TEXT NOT NULL DEFAULT [NULL]'];
    execute(conn, sqlquery);    
    sqlquery = ['ALTER TABLE Projects_Instances ADD Current_Analysis TEXT REFERENCES Analyses_Instances(UUID) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL DEFAULT [ZZZZZZ_ZZZ]'];
    execute(conn, sqlquery);
    % For testing only START
    if isTest 
        sqlquery = ['ALTER TABLE Projects_Instances ADD Current_Logsheet TEXT REFERENCES Logsheets_Instances(UUID) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL DEFAULT [ZZZZZZ_ZZZ]'];
        execute(conn, sqlquery);
        sqlquery = ['ALTER TABLE Projects_Instances ADD Process_Queue TEXT NOT NULL DEFAULT [NULL]'];
        execute(conn, sqlquery);
    end
    % END TESTING
end

if ismember('Process_Abstract',modifiedNames)
    sqlquery = ['ALTER TABLE Process_Abstract ADD InputVariablesNamesInCode TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Process_Abstract ADD OutputVariablesNamesInCode TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Process_Abstract ADD Level TEXT NOT NULL DEFAULT [''T'']'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Process_Abstract ADD ExecFileName TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
end

if ismember('Process_Instances',modifiedNames)
    sqlquery = ['ALTER TABLE Process_Instances ADD SpecifyTrials TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Process_Instances ADD Date_Last_Ran TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
end

if ismember('Variables_Abstract',modifiedNames)
    sqlquery = ['ALTER TABLE Variables_Abstract ADD IsHardCoded INTEGER NOT NULL DEFAULT (false)'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Variables_Abstract ADD Level TEXT NOT NULL DEFAULT [''T'']'];
    execute(conn, sqlquery);
end

if ismember('Variables_Instances',modifiedNames)
    sqlquery = ['ALTER TABLE Variables_Instances ADD HardCodedValue TEXT NOT NULL DEFAULT [NULL]'];
    execute(conn, sqlquery);
end

if ismember('SpecifyTrials_Abstract',modifiedNames)
    sqlquery = ['ALTER TABLE SpecifyTrials_Abstract ADD Logsheet_Parameters TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE SpecifyTrials_Abstract ADD Data_Parameters TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
end

% START TESTING
if isTest
    if ismember('Logsheets_Abstract',modifiedNames)
        sqlquery = ['ALTER TABLE Logsheets_Abstract ADD Logsheet_Path TEXT NOT NULL Default [NULL]'];
        execute(conn, sqlquery);
        sqlquery = ['ALTER TABLE Logsheets_Abstract ADD Num_Header_Rows INTEGER NOT NULL DEFAULT -1'];
        execute(conn, sqlquery);
        sqlquery = ['ALTER TABLE Logsheets_Abstract ADD Subject_Codename_Header TEXT NOT NULL Default [NULL]'];
        execute(conn, sqlquery);
        sqlquery = ['ALTER TABLE Logsheets_Abstract ADD Target_TrialID_Header TEXT NOT NULL Default [NULL]'];
        execute(conn, sqlquery);
        sqlquery = ['ALTER TABLE Logsheets_Abstract ADD LogsheetVar_Params TEXT NOT NULL Default [NULL]'];
        execute(conn, sqlquery);
    end
end
% END TESTING

if ismember('Logsheets_Instances',modifiedNames)
    sqlquery = ['ALTER TABLE Logsheets_Instances ADD Logsheet_Path TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Logsheets_Instances ADD Num_Header_Rows INTEGER NOT NULL DEFAULT -1'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Logsheets_Instances ADD Subject_Codename_Header TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Logsheets_Instances ADD Target_TrialID_Header TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Logsheets_Instances ADD LogsheetVar_Params TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Logsheets_Instances ADD SpecifyTrials TEXT NOT NULL Default [' jsonencode('NULL') ']'];
    execute(conn, sqlquery); 
end

if ismember('Analyses_Instances',modifiedNames)
    sqlquery = ['ALTER TABLE Analyses_Instances ADD Tags TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Analyses_Instances ADD Current_View TEXT REFERENCES Views_Instances ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL Default [NULL]'];
    execute(conn, sqlquery);    
    sqlquery = ['ALTER TABLE Analyses_Instances ADD Current_Logsheet TEXT REFERENCES Logsheets_Instances(UUID) ON DELETE RESTRICT ON UPDATE CASCADE NOT NULL DEFAULT [ZZZZZZ_ZZZ]'];
    execute(conn, sqlquery);
    sqlquery = ['ALTER TABLE Analyses_Instances ADD Process_Queue TEXT NOT NULL DEFAULT [NULL]'];
    execute(conn, sqlquery);
end

if ismember('Views_Instances',modifiedNames)
    sqlquery = ['ALTER TABLE Views_Instances ADD InclNodes TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
end

%% JOIN TABLES
createJoinTable = ['CREATE TABLE XXX_YYY (',...
    'AAA_ID TEXT REFERENCES CCC_Instances (UUID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL DEFAULT [ZZZZZZ_ZZZ], ',...
    'BBB_ID TEXT REFERENCES DDD_Instances (UUID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL DEFAULT [ZZZZZZ_ZZZ], ',...
    'PRIMARY KEY (AAA_ID, BBB_ID)',...
    ');'];
createJoinTable_VRPR = ['CREATE TABLE XXX_YYY (',...
    'AAA_ID TEXT REFERENCES CCC_Instances (UUID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL DEFAULT [ZZZZZZ_ZZZ], ',...
    'BBB_ID TEXT REFERENCES DDD_Instances (UUID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL DEFAULT [ZZZZZZ_ZZZ], ',...
    'NameInCode TEXT NOT NULL DEFAULT [NULL], ',...
    'PRIMARY KEY (AAA_ID, BBB_ID, NameInCode)',...
    ');'];

% Except for VR_PR and PR_VR, the left column is the parent, the right
% column is the child.
objAbbrevs = {{'PJ','AN'},{'AN','PR'},{'AN','PG'},{'PG','PR'},{'PG','PG'},...
    {'PR','VR'},{'VR','PR'},{'PJ','LG'},{'AN','VW'},{'AN','LG'},{'VR','LG'},{'AN','ST'}};
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

    class1 = className2Abbrev(abbrevs{1});
    class2 = className2Abbrev(abbrevs{2});
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

    if ismember(name,{'PR_VR','VR_PR'})
        createJoinTableTmp = createJoinTable_VRPR;
    else
        createJoinTableTmp = createJoinTable;
    end

    createJoinTableCurr = strrep(createJoinTableTmp,'XXX',abbrevs{1});
    createJoinTableCurr = strrep(createJoinTableCurr,'YYY',abbrevs{2});
    createJoinTableCurr = strrep(createJoinTableCurr,'AAA',newAbbrevs{1});
    createJoinTableCurr = strrep(createJoinTableCurr,'BBB',newAbbrevs{2});
    createJoinTableCurr = strrep(createJoinTableCurr,'CCC',class1);
    createJoinTableCurr = strrep(createJoinTableCurr,'DDD',class2);

    execute(conn, createJoinTableCurr);

end

%% Custom Join table columns
% Input variables.
if ismember('VR_PR',modifiedNames)
    sqlquery = ['ALTER TABLE VR_PR ADD Subvariable TEXT NOT NULL Default [NULL]'];
    execute(conn, sqlquery);
end

%% Settings table
% Put values into the table.
if ~ismember('Settings',tableNames)
    sqlquery = ['CREATE TABLE Settings (VariableName TEXT PRIMARY KEY NOT NULL UNIQUE DEFAULT [NULL],',...
        'VariableValue NOT NULL DEFAULT [NULL]);'];    
    execute(conn, sqlquery);

    % Initialize the settings in the table.
    VariableName = {'dbFile', 'Current_Project_Name','Current_Tab_Title','Current_User'}';
    VariableValue = {'NULL','NULL','NULL','NULL'}';
    t = table(VariableName, VariableValue);
    sqlwrite(conn, 'Settings', t);

    %% Now that the table has been initialized, put the proper values in it.
    % Computer ID
    computerID = getComputerID(); % Also sets the Computer ID
    % sqlquery = ['UPDATE Settings SET VariableValue = ''' computerID ''' WHERE VariableName = ''Computer_ID'''];
    % execute(conn, sqlquery);

    % DB file path
    dbFileNew.(computerID) = dbFile;
    sqlquery = ['UPDATE Settings SET VariableValue = ''' jsonencode(dbFileNew) ''' WHERE VariableName = ''dbFile'''];
    execute(conn, sqlquery);      

    % Current_User
    Current_User.(computerID) = 'Admin';
    sqlquery = ['UPDATE Settings SET VariableValue = ''' jsonencode(Current_User) ''' WHERE VariableName = ''Current_User'''];
    execute(conn, sqlquery); 
    Current_User = Current_User.(computerID);    

    % Current_Tab_Title
    Current_Tab_Title.(Current_User) = 'Projects';
    sqlquery = ['UPDATE Settings SET VariableValue = ''' jsonencode(Current_Tab_Title) ''' WHERE VariableName = ''Current_Tab_Title'''];
    execute(conn, sqlquery);    

    % Current_Project_Name

    % Try to get the second row of the Projects_Instances table. If there's
    % only one row (the initialization row), then create a new row, and set
    % the current project as its UUID.
    sqlquery = 'SELECT UUID, Date_Modified FROM Projects_Instances;';
    t = fetch(conn, sqlquery);
    t = table2MyStruct(t);    
    if isempty(fieldnames(t))
        abstractID = createID_Abstract('Project');
        instanceID = createID_Instance(abstractID, 'Project');
        uuid = genUUID('PJ',abstractID, instanceID);                

        Current_Project_Name.(Current_User) = uuid;
        sqlquery = ['UPDATE Settings SET VariableValue = ''' jsonencode(Current_Project_Name) ''' WHERE VariableName = ''Current_Project_Name'''];
        execute(conn, sqlquery);

        projStruct = createNewObject(false, 'Project', 'Default',abstractID,'', true);
        projStruct = createNewObject(true, 'Project', 'Default',abstractID,instanceID, true);
        % setCurrent(projStruct.Current_Analysis.(Current_User), 'Current_Analysis');
    else % Projects instances already exists, but the Settings table is being rebuilt for some reason.        
        dates = t.Date_Modified;
        dates = datetime(dates);
        [~,idx] = max(dates);
        uuid = t.UUID(idx(1));

        Current_Project_Name.(Current_User.(computerID)) = uuid;
        sqlquery = ['UPDATE Settings SET VariableValue = ''' jsonencode(Current_Project_Name) ''' WHERE VariableName = ''Current_Project_Name'''];
        execute(conn, sqlquery);
    end       
end