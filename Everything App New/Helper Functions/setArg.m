function []=setArg(id,subName,trialName,repNum,varargin)

%% PURPOSE: SAVE THE DATA

if ~isnumeric(id)
    error('ID must be a number!');
end

try
    runInfo=evalin('base','runInfo');
catch
    error('Missing ''runInfo'' from base workspace');
end

if ~isfield(runInfo,'SetArgIDsUsed')
    runInfo.SetArgIDsUsed=[];
end
if ~ismember(id,runInfo.SetArgIDsUsed)
    runInfo.SetArgIDsUsed=[runInfo.SetArgIDsUsed; id];
    assignin('base','runInfo',runInfo);
end

dataPath=runInfo.DataPath;

if nargin<4
    error('Need to provide at least 4 inputs to setArg');
end

if isempty(subName)
    level='P';
elseif isempty(trialName)
    level='S';
else
    level='T';
end
uuids = runInfo.Output.VR_ID;
namesInCode = runInfo.Output.NameInCode;
levels = runInfo.Output.Level;

absNamesInCode = runInfo.Output.AbsNamesInCode;

for i=1:length(absNamesInCode)

    currVars=absNamesInCode{i};

    if ~isequal(currVars{1},id)
        continue; % Ensure that only the desired setArg ID is used.
    end

    currVarsIdx = ismember(namesInCode, currVars(2:end));

    currNamesInCode = namesInCode(currVarsIdx);
    currUUIDs = uuids(currVarsIdx);
    currLevels = levels(currVarsIdx);

    for j=2:length(currVars)

        varIdx = ismember(currNamesInCode,currVars{j});

        if ~any(varIdx)
            continue;
        end

        uuid = currUUIDs{varIdx};
        varLevel = currLevels{varIdx};

        if level<varLevel
            error('Missing subject and/or trial name specification');
        end

        switch varLevel
            case 'P'
                saveMAT(dataPath,currVars{j},uuid,varargin{j-1});
            case 'S'
                saveMAT(dataPath,currVars{j},uuid,varargin{j-1},subName);
            case 'T'
                saveMAT(dataPath,currVars{j},uuid,varargin{j-1},subName,trialName);
        end

    end

    % If this point is reached, it's because all variables have been saved.
    return;

end

% If this point is reached, the setArg was not used.
error('Forgot to add this setArg ID!');