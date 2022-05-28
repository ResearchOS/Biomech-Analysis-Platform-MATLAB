function []=logsheetPathFieldValueChanged(src,event)

%% PURPOSE: UPDATE THE LOGSHEET PATH FIELD VALUE, AND SAVE A COPY OF THE XLSX FILE TO MAT FILE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

logsheetPath=handles.Import.logsheetPathField.Value;

if isempty(logsheetPath) || isequal(logsheetPath,'Logsheet Path (ends in .xlsx)')
    setappdata(fig,'logsheetPath','');
    return;
end

if exist(logsheetPath,'file')~=2
    warning(['Incorrect logsheet path: ' logsheetPath]);
    return;
end

if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end

setappdata(fig,'logsheetPath',logsheetPath);

% Save the data path to the project-specific settings
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

[~,hostname]=system('hostname'); % Get the name of the current computer
hostVarName=genvarname(hostname); % Generate a valid MATLAB variable name from the computer host name.

projectSettingsMATPath=settingsStruct.(hostVarName).projectSettingsMATPath;

projectSettingsStruct=load(projectSettingsMATPath);
projectSettingsStruct=projectSettingsStruct.(projectName);

projectSettingsStruct.Import.Paths.(hostVarName).LogsheetPath=logsheetPath;
[logsheetFolder,name,ext]=fileparts(logsheetPath);
logsheetPathMAT=[logsheetFolder name '.mat'];

if contains(ext,'xls')
    [~,~,logsheetVar]=xlsread(logsheetPath,1);
end

save(logsheetPathMAT,'logsheetVar');

projectSettingsStruct.Import.Paths.(hostVarName).LogsheetPathMAT=logsheetPathMAT;

eval([projectName '=projectSettingsStruct;']); % Rename the projectSettingsStruct to the projectName

save(projectSettingsMATPath,projectName,'-append');