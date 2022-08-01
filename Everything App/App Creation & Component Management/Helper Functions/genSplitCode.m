function [splitCode]=genSplitCode(projectSettingsMATPath,splitName)

%% PURPOSE: GENERATE A CODE FOR THE SPECIFIED SPLIT
% Inputs:
% projectSettingsMATPath: The full file name to the .mat file for the
% current project's settings (char)
% splitName: The name of the current split (char)

% Outputs:
% splitCode: The three character code corresponding to a specific split

projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

if ~ismember('NonFcnSettingsStruct',projectSettingsVarNames)
    splitCode='001';
    return;
end

load(projectSettingsMATPath,'NonFcnSettingsStruct');

if isfield(NonFcnSettingsStruct.Process.Splits,splitName)
    splitCode=NonFcnSettingsStruct.Process.Splits.(splitName).Code;
    return;
end

splitNames=fieldnames(NonFcnSettingsStruct.Process.Splits);

splitCodes=NaN(length(splitNames),1);
for i=1:length(splitNames)
    splitCodes(i)=str2double(NonFcnSettingsStruct.Process.Splits.(splitNames{i}).Code);
end

splitCode=max(splitCodes)+1;

switch splitCode
    case splitCode>=100
        splitCode=num2str(splitCode);
    case splitCode>=10
        splitCode=['0' num2str(splitCode)];
    otherwise
        splitCode=['00' num2str(splitCode)];
end