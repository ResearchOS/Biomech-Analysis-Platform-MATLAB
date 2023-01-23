function []=setArg(id,subName,trialName,varargin)

%% PURPOSE: SAVE THE DATA

try
    runInfo=evalin('base','runInfo');
catch
    error('Missing ''runInfo'' from base workspace');
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
                saveMAT(dataPath,desc,psText,varargin{j-1});
            case 'S'
                saveMAT(dataPath,desc,psText,varargin{j-1},subName);
            case 'T'
                saveMAT(dataPath,desc,psText,varargin{j-1},subName,trialName);
        end

    end

    % If this point is reached, it's because all variables have been saved.
    return;

end