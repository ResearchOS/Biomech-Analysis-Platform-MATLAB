function []=setCurrent(var, varName)

%% PURPOSE: SET THE CURRENT VARIABLE IN THE SETTINGS FILE.

global conn;
clearAllMemoizedCaches;

%% Look at Settings table to determine.
rootSettingsVars = {'commonPath', 'Computer_ID', 'Current_Project_Name',...
    'Current_Tab_Title'};

if ismember(varName,rootSettingsVars)
    % t = table;
    % t.VariableName = varName;
    % t.VariableValue = var;
    % t = table(varName,var,'VariableNames',{'VariableName','VariableValue'});
    % sqlquery = ['SELECT * FROM Settings'];
    % t = fetch(conn, sqlquery);
    % tIdx = ismember(t.VariableNames,varName);
    % t.Value(tIdx) = var;
    % rf = rowfilter("VariableName");
    % rf = rf.VariableName==varName;
    sqlquery = ['UPDATE Settings SET VariableValue = ''' var ''' WHERE VariableName = ''' varName ''''];
    execute(conn, sqlquery);
    % sqlupdate(conn, 'Settings',t,{rf});
end


%% Look at projects table to determine.
projectSettingsVars = {'DataPath','ProjectPath','Process_Queue',...
    'Current_Analysis','Current_Logsheet'};

if ismember(varName, projectSettingsVars)    
    projectName = getCurrent('Current_Project_Name');
    currVal = getCurrent(varName);
    if ismember(varName,{'DataPath','ProjectPath'})
        computerID = getCurrent('Computer_ID');
        currVal.(computerID) = var;
        currVal = jsonencode(currVal);
    else
        currVal = var;
    end
    % t = table(currVal,'VariableName',varName);
    % rf = rowfilter('UUID');
    % rf = rf.UUID==projectName;
    sqlquery = ['UPDATE Projects_Instances SET ' varName ' = ''' currVal ''' WHERE UUID = ''' projectName ''''];
    execute(conn, sqlquery);
    % sqlupdate(conn, 'Projects_Instances', t, rf);
end