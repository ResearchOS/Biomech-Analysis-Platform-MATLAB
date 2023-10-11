function [var] = getCurrent(varName,withID)

%% PURPOSE: RETURN THE VARIABLE FROM THE CURRENT SETTINGS VARIABLE
% withID: Return the paths with computer ID. Most likely being called by
% setCurrent.

if nargin==1
    withID = false;
end

var = memoizedGetCurrent(varName, withID);
% h = @memoizedGetCurrent;
% fcnH = memoize(h);
% var = fcnH(varName, withID);

end

function [var] = memoizedGetCurrent(varName, withID)
var = [];

%% Computer ID
% Runs the first time, then will be memoized (and therefore faster)
if isequal(varName,'Computer_ID')
    var = getComputerID();
end

%% Look at Settings table to determine.
rootSettingsVars = {'dbFile', 'Current_Project_Name',...
    'Current_Tab_Title','Current_User'};

if ismember(varName,rootSettingsVars)  
    sqlquery = ['SELECT VariableValue FROM Settings WHERE VariableName = ''' varName ''''];
    var = fetchQuery(sqlquery,'char');
    var = var.VariableValue;
    if isempty(var)
        var = '';
        return;
    end  
    var = jsondecode(var);
    if ismember(varName,{'dbFile','Current_User'})        
        computerID = getCurrent('Computer_ID'); 
        if ~withID
            var = char(var.(computerID));
        end
    elseif ismember(varName,{'Current_Project_Name','Current_Tab_Title'})        
        Current_User = getCurrent('Current_User');
        if ~withID
            var = char(var.(Current_User));
        end
    end    
end

%% Look at projects table to determine.
projectSettingsVars = {'Data_Path','Project_Path','Current_Analysis'};

if ismember(varName,projectSettingsVars)            
    projectName = getCurrent('Current_Project_Name');
    sqlquery = ['SELECT ' varName ' FROM Projects_Instances WHERE UUID = ''' projectName ''';'];
    struct = fetchQuery(sqlquery);
    if isempty(struct.(varName))
        var = '';
        return;
    end
    if ismember(varName,{'Data_Path','Project_Path'})
        computerID = getCurrent('Computer_ID');
        if ~withID            
            var = char(struct.(varName).(computerID)); 
        else
            var = struct.(varName);
        end
    elseif ismember(varName,{'Current_Analysis'})
        Current_User = getCurrent('Current_User');
        if ~withID            
            var = char(struct.(varName).(Current_User));
        else
            var = struct.(varName);
        end
    else
        var = char(struct.(varName));
    end

end

%% Look at analyses table to determine
analysisSettingsVars = {'Current_View','Current_Logsheet','Process_Queue'};

if ismember(varName,analysisSettingsVars)    
    Current_User = getCurrent('Current_User');
    analysisName = getCurrent('Current_Analysis');
    sqlquery = ['SELECT ' varName ' FROM Analyses_Instances WHERE UUID = ''' analysisName ''';'];
    struct = fetchQuery(sqlquery);
    if isempty(struct.(varName))
        var = '';
        return;
    end
    if ~withID
        if isstring(struct.(varName).(Current_User))
            var = char(struct.(varName).(Current_User));
        else
            if iscell(struct.(varName).(Current_User)) && iscell(struct.(varName).(Current_User){1})
                var = struct.(varName).(Current_User){1};
            else
                var = struct.(varName).(Current_User);
            end
        end
    else
        var = struct.(varName);
    end
end

end