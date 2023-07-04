function [var] = getCurrent(varName)

%% PURPOSE: RETURN THE VARIABLE FROM THE CURRENT SETTINGS VARIABLE
% List of variables in this settings file:

var = [];

rootSettingsVars = {'commonPath', 'Computer_ID', 'Current_Project_Name',...
    'Current_Tab_Title','Store_Settings'};

if ismember(varName,rootSettingsVars)
    try
        rootSettingsFile = getRootSettingsFile();
        var = load(rootSettingsFile, varName);
        var = var.(varName);
    catch
    end
    return;
end

projectSettingsVars = {'DataPath','ProjectPath','Process_Queue','Current_Analysis',...
    'Current_Logsheet'};

if ismember(varName,projectSettingsVars)
    try
        projectName = getCurrent('Current_Project_Name');
        projectSettings = loadJSON(projectName);

        if contains(varName,'Path')
            computerID = getCurrent('Computer_ID');
            var = projectSettings.(computerID).(varName);
        else
            var = projectSettings.(varName);
        end
    catch
    end
    return;
end