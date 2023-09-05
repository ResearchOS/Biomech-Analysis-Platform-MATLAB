function [] = transferColumns()

%% PURPOSE: MOVE COLUMNS FROM PROJECT TO ANALYSIS.

global conn;

% 1. Current_Logsheet: PJ -> AN (per User)
% 2. Process_Queue: PJ -> AN (per User)
% 3. Current_Project_Name: PJ -> PJ (per User)
% 4. Current_Analysis: PJ -> PJ (per User)

%% Set the current objects.
Current_Project = 'PJ7D2867_B46'; % The project I've been using.

Current_User = getCurrent('Current_User');
currAn.(Current_User) = 'ANF4D23E_83B';
sqlquery = ['UPDATE Projects_Instances SET Current_Analysis = ''' jsonencode(currAn) ''' WHERE UUID = ''' Current_Project ''';'];
execute(conn, sqlquery);
setCurrent(Current_Project,'Current_Project_Name'); % 3.

Current_Analysis = 'ANF4D23E_83B';
setCurrent(Current_Analysis,'Current_Analysis'); % 4.

Current_View = getCurrent('Current_View');
% vwStruct = createNewObject(true, 'VW', 'ALL', '000000','',true);
setCurrent(Current_View, 'Current_View');

%% Logsheet from project to analysis per user.
lgAbsNew = loadJSON('LG71F125'); % NumHeaderRows, CodenameHeader, TargetTrialID, LogsheetVar_Params
sqlquery = ['SELECT UUID FROM Logsheets_Instances'];
t = fetch(conn, sqlquery);
lgInst = loadJSON(char(t.UUID)); % LogsheetPath
fldNames = {'Num_Header_Rows','Subject_Codename_Header','Target_TrialID_Header','LogsheetVar_Params'};
for i=1:length(fldNames)
    lgInst.(fldNames{i}) = lgAbsNew.(fldNames{i});
end
instanceID = createID_Instance(lgAbsNew.UUID, 'Logsheet');
lgUUID = genUUID('LG',lgAbsNew.UUID(3:end), instanceID);
lgInst.UUID = lgUUID;
lgInst.Abstract_UUID = lgAbsNew.UUID;
saveClass(lgInst); % Make new logsheet instance to match the existing abstract logsheet.
setCurrent(lgInst.UUID,'Current_Logsheet'); % 1.

%% Process queue from project to analysis per user.
pq.(Current_User) = {};
sqlquery = ['UPDATE Analyses_Instances SET Process_Queue = ''' jsonencode(pq) ''' WHERE UUID = ''' Current_Analysis ''';'];
execute(conn, sqlquery);
setCurrent({},'Process_Queue'); % 2.

%% Assign the abstract ST to the AN_ST table.
sqlquery = ['SELECT UUID FROM SpecifyTrials_Abstract'];
t = fetch(conn, sqlquery);
t = table2MyStruct(t);
for i=1:length(t.UUID)
    linkObjs(Current_Analysis, t.UUID{i}); % Link specify trials abstract ID to analysis ID
end