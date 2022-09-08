function [splitCode,NonFcnSettingsStruct]=genSplitCode(projectSettingsMATPath,splitsList,name)

%% PURPOSE: GENERATE A CODE FOR THE SPECIFIED SPLIT
% Inputs:
% projectSettingsMATPath: The full file name to the .mat file for the
% current project's settings (char)
% splitName: The name of the current split (char)

% Outputs:
% splitCode: The three character code corresponding to a specific split

splitsList=[splitsList; {name}]; % The desired split was selected, so it will always be at the end.

projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

if ~ismember('NonFcnSettingsStruct',projectSettingsVarNames) && ~ismember('maxSplitCode',projectSettingsVarNames)
    splitCode='001';
    maxSplitCode=splitCode;
    save(projectSettingsMATPath,'maxSplitCode','-append');
    return;
end

% load(projectSettingsMATPath,'NonFcnSettingsStruct');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');

if ~isfield(NonFcnSettingsStruct,'Process') && ~ismember('maxSplitCode',projectSettingsVarNames)
    splitCode='001';
    maxSplitCode=splitCode;
    save(projectSettingsMATPath,'maxSplitCode','-append');
    return;
end

if ~ismember('maxSplitCode',projectSettingsVarNames)
    disp('Missing the maxSplitCode variable in the project settings file!');
    splitCode='';
    return;
end
load(projectSettingsMATPath,'maxSplitCode');
splits=NonFcnSettingsStruct.Process.Splits;

splitCodes=cell(length(splitsList),1);
for i=1:length(splitsList)
    if isfield(splits,'SubSplitNames') && isfield(splits.SubSplitNames,splitsList{i})
        splitCodes{i}=splits.SubSplitNames.(splitsList{i}).Code;
        splits=splits.SubSplitNames.(splitsList{i});
    end    
end

if isempty(splitCodes{end})
    splitCode=str2double(maxSplitCode)+1; % This is a new split, so create a new code for it.
else
    splitCode=splitCodes{ismember(splitsList,name)}; % Grab an existing split code. Should always be at the end
    return; % Already a char
end

if splitCode>=100
    splitCode=num2str(splitCode);
elseif splitCode>=10
    splitCode=['0' num2str(splitCode)];
else
    splitCode=['00' num2str(splitCode)];
end

maxSplitCode=splitCode;
save(projectSettingsMATPath,'maxSplitCode','-append');