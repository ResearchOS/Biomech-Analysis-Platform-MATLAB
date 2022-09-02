function []=targetTrialIDFormatFieldValueChanged(src,targetTrialIDColHeaderName)

%% PURPOSE: SET & STORE THE TARGET TRIAL ID COLUMN HEADER NAME FROM THE LOGSHEET   

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

if exist('targetTrialIDColHeaderName','var')~=1
    targetTrialIDColHeaderName=handles.Import.targetTrialIDColHeaderField.Value;
    runLog=true;
else
    handles.Import.targetTrialIDColHeaderField.Value=targetTrialIDColHeaderName;
    runLog=false;
end

if isempty(targetTrialIDColHeaderName)
    return;
end

% Save the target trial ID column header to the project-specific settings
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

macAddress=getComputerID();

projectSettingsMATPath=settingsStruct.(macAddress).projectSettingsMATPath;

NonFcnSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct');
NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;

NonFcnSettingsStruct.Import.TargetTrialIDColHeader=targetTrialIDColHeaderName;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

if runLog
    desc='Change the target trial ID column header name from the logsheet';
    updateLog(fig,desc,targetTrialIDColHeaderName);
    logsheetPath=getappdata(fig,'logsheetPath');
    logsheetPathFieldValueChanged(fig,logsheetPath);
else
    logsheetPathFieldValueChanged(fig);
end