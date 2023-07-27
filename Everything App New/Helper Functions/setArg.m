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

st=dbstack;
st(2).name;

instStructFcn=runInfo.Fcn.InstStruct;

outputVars=instStructFcn.OutputVariables;

for i=1:length(outputVars)

    currVars=outputVars{i};

    if ~isequal(currVars{1},id)
        continue; % Ensure that only the desired setArg ID is used.
    end

    for j=2:length(currVars)

        instStruct=runInfo.Var.Output(i).InstStruct{j-1};
        absStruct=runInfo.Var.Output(i).AbsStruct{j-1};
        varLevel=absStruct.Level;

        uuid=instStruct.UUID;

        if level<varLevel
            error('Missing subject and/or trial name specification');
        end

        switch varLevel
            case 'P'
                saveMAT(dataPath,instStructFcn,uuid,varargin{j-1});
            case 'S'
                saveMAT(dataPath,instStructFcn,uuid,varargin{j-1},subName);
            case 'T'
                saveMAT(dataPath,instStructFcn,uuid,varargin{j-1},subName,trialName);
        end

    end

    % If this point is reached, it's because all variables have been saved.
    return;

end

% If this point is reached, the setArg was not used.
error('Forgot to add this setArg ID!');