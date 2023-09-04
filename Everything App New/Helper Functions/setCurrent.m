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
    sqlquery = ['UPDATE Settings SET VariableValue = ''' var ''' WHERE VariableName = ''' varName ''';'];
    execute(conn, sqlquery);   
end

%% Look at projects table to determine.
projectSettingsVars = {'DataPath','ProjectPath','Process_Queue',...
    'Current_Analysis','Current_Logsheet'};

if ismember(varName, projectSettingsVars)    
    projectName = getCurrent('Current_Project_Name');    
    if ismember(varName,{'DataPath','ProjectPath'})
        computerID = getCurrent('Computer_ID');
        currVal = getCurrent(varName, true);
        currVal.(computerID) = var;
        currVal = jsonencode(currVal);
    elseif ismember(varName,{'Process_Queue'})
        currVal = jsonencode(var);
    else
        currVal = var;
    end    
    sqlquery = ['UPDATE Projects_Instances SET ' varName ' = ''' currVal ''' WHERE UUID = ''' projectName ''';'];
    execute(conn, sqlquery);    
end

%% Look at analysis table to determine.
analysisSettingsVars = {'Current_View'};
if ismember(varName,analysisSettingsVars)
    analysisName = getCurrent('Current_Analysis');
    computerID = getCurrent('Computer_ID');
    currVal = getCurrent(varName, true);
    currVal.(computerID) = var;        
    currVal = jsonencode(currVal);
    sqlquery = ['UPDATE Analyses_Instances SET ' varName ' = ''' currVal ''' WHERE UUID = ''' analysisName ''';'];
    execute(conn, sqlquery);    
end

if isequal(varName,'Current_View')
    Current_Analysis = getCurrent('Current_Analysis');
    linkObjs(var, Current_Analysis);
end

if isequal(varName,'Current_Analysis')
    Current_Project = getCurrent('Current_Project_Name');
    Current_View = getCurrent('Current_View');
    linkObjs(var, Current_Project);
    linkObjs(var, Current_View);
end

if isequal(varName, 'Current_Project_Name')
    Current_Analysis = getCurrent('Current_Analysis');
    linkObjs(var, Current_Analysis);
end