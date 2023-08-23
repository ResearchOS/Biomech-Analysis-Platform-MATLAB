function []=setCurrent(var, varName)

%% PURPOSE: SET THE CURRENT VARIABLE IN THE SETTINGS FILE.

clearAllMemoizedCaches;

rootSettingsVars = {'commonPath', 'Computer_ID', 'Current_Project_Name',...
    'Current_Tab_Title'};

if ismember(varName,rootSettingsVars)
    t = table(var,'VariableNames','VariableNames');
    % sqlquery = ['SELECT * FROM Settings'];
    % t = fetch(conn, sqlquery);
    % tIdx = ismember(t.VariableNames,varName);
    % t.Value(tIdx) = var;
    rf = rowfilter('VariableNames');
    rf = rf.VariableNames==varName;
    sqlupdate(conn, 'Settings',t,rf);
end

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
    t = table(currVal,'VariableNames',varName);
    rf = rowfilter('UUID');
    rf = rf.UUID==projectName;
    sqlupdate(conn, 'Projects_Instances', t, rf);
end