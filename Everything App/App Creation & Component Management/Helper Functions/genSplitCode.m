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

if ~ismember('VariableNamesList',projectSettingsVarNames)
    splitCode='001';
    return;
end

load(projectSettingsMATPath,'VariableNamesList');

if ismember(splitName,VariableNamesList.SplitNames)
    splitIdx=ismember(VariableNamesList.SplitNames,splitName);
    splitCode=unique(VariableNamesList.SplitCodes(splitIdx));
    splitCode=splitCode{1};
    assert(all(ismember(splitName,VariableNamesList.SplitNames(splitIdx)))); % Ensure that all of the split names are identical
    return;
end

splitNums=str2double(VariableNamesList.SplitCodes);
splitCode=max(splitNums)+1;

switch splitCode
    case splitCode>=100
        splitCode=num2str(splitCode);
    case splitCode>=10
        splitCode=['0' num2str(splitCode)];
    otherwise
        splitCode=['00' num2str(splitCode)];
end


% key={'0','1','2','3','4','5','6','7','8','9',...
%     'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',...
%     'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
% 
% rng default;
% 
% for i=1:iters
%     nums=randi(length(key),3);
% end
% 
% nums=nums(1,1:3);
% 
% splitCodeUnchecked='111'; % Initialize
% for i=1:length(nums)
%     splitCodeUnchecked(1,i)=key{nums(i)};
% end
% 
% splitCode=splitCodeUnchecked;

% Check the split code against the list of existing split codes for this
% project