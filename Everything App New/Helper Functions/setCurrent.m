function []=setCurrent(var, varName)

%% PURPOSE: SET THE CURRENT VARIABLE IN THE SETTINGS FILE.

global conn;
clearAllMemoizedCaches;

%% Look at Settings table to determine.
rootSettingsVars = {'commonPath', 'Computer_ID', 'Current_Project_Name',...
    'Current_Tab_Title'};

if ismember(varName,rootSettingsVars)
    if ismember(varName,{'commonPath'})
        computerID = getCurrent('Computer_ID');
        commonPath = getCurrent('commonPath');
        commonPath.(computerID) = var;
        var = jsonencode(commonPath);
    end
    sqlquery = ['UPDATE Settings SET VariableValue = ''' var ''' WHERE VariableName = ''' varName ''''];
    execute(conn, sqlquery);   
end


%% Look at projects table to determine.
projectSettingsVars = {'DataPath','ProjectPath','Process_Queue',...
    'Current_Analysis','Current_Logsheet'};

if ismember(varName, projectSettingsVars)    
    projectName = getCurrent('Current_Project_Name');    
    if ismember(varName,{'DataPath','ProjectPath'})
        computerID = getCurrent('Computer_ID');
        currVal = getCurrent(varName);
        currVal.(computerID) = var;
        currVal = jsonencode(currVal);
    else
        currVal = var;
    end    
    sqlquery = ['UPDATE Projects_Instances SET ' varName ' = ''' currVal ''' WHERE UUID = ''' projectName ''''];
    execute(conn, sqlquery);
    % sqlupdate(conn, 'Projects_Instances', t, rf);
end