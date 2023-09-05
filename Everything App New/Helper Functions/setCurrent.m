function []=setCurrent(var, varName)

%% PURPOSE: SET THE CURRENT VARIABLE IN THE SETTINGS FILE.

global conn;
clearAllMemoizedCaches;

% prevVal = getCurrent(varName); % The previous value, to store in the undo/redo stack.


%% Look at Settings table to determine.
rootSettingsVars = {'dbFile', 'Current_Project_Name',...
    'Current_Tab_Title','Current_User'};

if ismember(varName,rootSettingsVars)
    if ismember(varName,{'dbFile','Current_User'})
        computerID = getComputerID();
        currVal = getCurrent(varName, true);
        currVal.(computerID) = var;        
    elseif ismember(varName,{'Current_Project_Name','Current_Tab_Title'})
        Current_User = getCurrent('Current_User');
        currVal = getCurrent(varName, true);
        currVal.(Current_User) = var;        
    end
    var = jsonencode(currVal);
    sqlquery = ['UPDATE Settings SET VariableValue = ''' var ''' WHERE VariableName = ''' varName ''';'];          
    execute(conn, sqlquery);
    if isequal(varName,'Current_Project_Name')
        linkObjs(currVal.(Current_User), getCurrent('Current_Analysis'));
    end
end

%% Look at projects table to determine.
projectSettingsVars = {'DataPath','ProjectPath',...
    'Current_Analysis'};

if ismember(varName, projectSettingsVars)    
    Current_Project = getCurrent('Current_Project_Name');
    if isempty(Current_Project)
        return;
    end
    if ismember(varName,{'DataPath','ProjectPath'})
        computerID = getComputerID();
        currVal = getCurrent(varName, true);
        currVal.(computerID) = var;
        currVal = jsonencode(currVal);
    elseif ismember(varName,{'Current_Analysis'})
        Current_User = getCurrent('Current_User');
        currVal = getCurrent(varName, true);
        currVal.(Current_User) = var;            
    end
    currVal = jsonencode(currVal);
    sqlquery = ['UPDATE Projects_Instances SET ' varName ' = ''' currVal ''' WHERE UUID = ''' Current_Project ''';'];
    execute(conn, sqlquery); 
    if isequal(varName,'Current_Analysis')
        linkObjs(var, Current_Project);
        Current_View = getCurrent('Current_View');
        linkObjs(var,Current_View);        
    end
end

%% Look at analysis table to determine.
analysisSettingsVars = {'Current_View','Current_Logsheet','Process_Queue'};
if ismember(varName,analysisSettingsVars)
    Current_Analysis = getCurrent('Current_Analysis');
    Current_User = getCurrent('Current_User');
    if isempty(Current_Analysis)
        return;
    end    
    currVal = getCurrent(varName, true);
    currVal.(Current_User) = var;        
    currVal = jsonencode(currVal);
    sqlquery = ['UPDATE Analyses_Instances SET ' varName ' = ''' currVal ''' WHERE UUID = ''' Current_Analysis ''';'];
    execute(conn, sqlquery);
    if ismember(varName,{'Current_View','Current_Logsheet'})
        linkObjs(var, Current_Analysis);
    end
end