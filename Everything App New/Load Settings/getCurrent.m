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
    if ismember(varName,{'commonPath'})
        var = jsondecode(var);
        computerID = getCurrent('Computer_ID');
        var = var.(computerID);
    end
    var = char(var);
end

%% Look at projects table to determine.
projectSettingsVars = {'Data_Path','Project_Path','Current_Analysis',...
    'Current_Logsheet','Process_Queue'};

if ismember(varName,projectSettingsVars)        
    computerID = getCurrent('Computer_ID');
    projectName = getCurrent('Current_Project_Name');
    sqlquery = ['SELECT ' varName ' FROM Projects_Instances WHERE UUID = ''' projectName ''';'];
    t = fetch(conn, sqlquery);
    struct = table2MyStruct(t);
    if isstruct(struct.(varName))
        var = struct.(varName).(computerID);
    else
        var = struct.(varName);
    end

end

end