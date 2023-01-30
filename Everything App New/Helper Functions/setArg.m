function []=setArg(id,subName,trialName,varargin)

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

st=dbstack;
st(2).name;

psStructFcn=runInfo.Fcn.PSStruct;

outputVars=psStructFcn.OutputVariables;

for i=1:length(outputVars)

    currVars=outputVars{i};

    if ~isequal(currVars{1},id)
        continue; % Ensure that only the desired setArg ID is used.
    end

    for j=2:length(currVars)

        psStruct=runInfo.Var.Output(i).PSStruct{j-1};

        psText=psStruct.Text;

        switch level
            case 'P'
                saveMAT(dataPath,psStructFcn,psText,varargin{j});
            case 'S'
                saveMAT(dataPath,psStructFcn,psText,varargin{j},subName);
            case 'T'
                saveMAT(dataPath,psStructFcn,psText,varargin{j},subName,trialName);
        end

    end

    % If this point is reached, it's because all variables have been saved.
    return;

end

% If this point is reached, the setArg was not used.
error('Forgot to add this setArg ID!');