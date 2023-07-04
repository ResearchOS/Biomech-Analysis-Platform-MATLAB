function []=setCurrent(var, varName)

%% PURPOSE: SET THE CURRENT VARIABLE IN THE SETTINGS FILE.

rootSettingsVars = {'commonPath', 'Computer_ID', 'Current_Project_Name',...
    'Current_Tab_Title','Store_Settings'};

if ismember(varName,rootSettingsVars)
    rootSettingsFile = getRootSettingsFile();
    varName = eval([varName ' = var;']); % Convert from var name to value
    save(rootSettingsFile,varName, '-append');
end

projectSettingsVars = {'DataPath','ProjectPath','Process_Queue','Current_Analysis',...
    'Current_Logsheet'};

if ismember(varName, projectSettingsVars)
    projectName = getCurrent('Current_Project_Name');
    projectStruct = loadJSON(projectName);

    if contains(upper(varName),'PATH')
        computerID = getCurrent('Computer_ID');
        projectStruct.(computerID).(varName) = var;
    else
        projectStruct.(varName) = var;
    end
    writeJSON(getJSONPath(projectName),projectStruct);
end