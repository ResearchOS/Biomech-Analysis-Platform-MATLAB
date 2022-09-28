function []=addLogVarsRunCode(useHeaderNames,dataTypes,trialSubject)

%% PURPOSE: IN THE RUN CODE, ADD THE LOGSHEET VARIABLES TO THE NONFCNSETTINGSSTRUCT
useHeaderVarNames=genvarname(useHeaderNames);

try
    NonFcnSettingsStruct=evalin('base','NonFcnSettingsStruct');
catch
    disp('NonFcnSettingsStruct missing from base workspace! Initializing as empty.');
    NonFcnSettingsStruct='';
end

for i=1:length(useHeaderNames)
    NonFcnSettingsStruct.Import.LogsheetVars.(useHeaderVarNames{i}).DataType=dataTypes{i};
    NonFcnSettingsStruct.Import.LogsheetVars.(useHeaderVarNames{i}).TrialSubject=trialSubject{i};
end

try
    projectSettingsMATPath=evalin('base','projectSettingsMATPath;');
catch
    disp('Missing the projectSettingsMATPath variable from the base workspace! Stopping.');
    return;
end

assignin('base','NonFcnSettingsStruct',NonFcnSettingsStruct);
save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');