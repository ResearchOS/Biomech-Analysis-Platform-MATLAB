function [var] = getCurrent(varName)

%% PURPOSE: RETURN THE VARIABLE FROM THE CURRENT SETTINGS VARIABLE

h = @memoizedGetCurrent;
fcnH = memoize(h);
var = fcnH(varName);

end

function [var] = memoizedGetCurrent(varName)
var = [];
global conn;

%% Look at Settings table to determine.
rootSettingsVars = {'commonPath', 'Computer_ID', 'Current_Project_Name',...
    'Current_Tab_Title'};

if ismember(varName,rootSettingsVars)  
    sqlquery = ['SELECT VariableValue FROM Settings WHERE VariableName = ''' varName ''''];
    var = fetch(conn, sqlquery);
    var = var.VariableValue;    
end


%% Look at projects table to determine.
projectSettingsVars = {'DataPath','ProjectPath','Current_Analysis',...
    'Current_Logsheet','Process_Queue'};

if ismember(varName,projectSettingsVars)        
    computerID = getCurrent('Computer_ID');
    projectName = getCurrent('Current_Project_Name');
    sqlquery = ['SELECT ' varName ' FROM Projects_Instances WHERE UUID = ' projectName];
    var = fetch(conn, sqlquery);

    if ismember(varName,{'DataPath','ProjectPath'})
        var = jsondecode(var);
        var = var.(computerID);
    end

end

end