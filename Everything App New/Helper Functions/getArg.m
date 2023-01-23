function [varargout]=getArg(id,subName,trialName,repNum)

%% PURPOSE: RETURN INPUT ARGUMENTS TO A PROCESSING FUNCTION

try
    runInfo=evalin('base','runInfo');
catch
    error('Missing ''runInfo'' from base workspace');
end

dataPath=runInfo.DataPath;

switch nargin
    case 4
        level='T';
    case 3
        level='T';
    case 2
        level='S';
    case 1
        level='P';
    case 0
        error('Need to specify getArg ID at minimum (nargin>=1)');    
end

% piStructFcn=runInfo.Fcn.PIStruct;
psStructFcn=runInfo.Fcn.PSStruct;

% Get the actual variable names as stored in file.
inputVars=psStructFcn.InputVariables;

for i=1:length(inputVars)

    currVars=inputVars{i};

    if ~isequal(currVars{1},id)
        continue; % Ensure that only the desired getArg ID is used.
    end

    varargout=cell(1,length(currVars)-1); % Initialize output variables.

    for j=2:length(currVars)        

        psStruct=runInfo.Var.Input(i).PSStruct{j-1};
        piStruct=runInfo.Var.Input(i).PIStruct{j-1};

        % 1. If hard-coded, use value stored in struct and continue.
        if piStruct.IsHardCoded
            varargout{j-1}=psStruct.HardCodedValue;
            continue;
        end

        % 3. If dynamic, find the proper file by looking at its text,
        % level, and subName/trialName/repNum values.
        psText=psStruct.Text;
%         varLevel=piStruct.Level;

        % 4. Load the dynamic variable.
        switch level
            case 'P'
                varargout{j-1}=loadMAT(dataPath,psText);
            case 'S'
                varargout{j-1}=loadMAT(dataPath,psText,subName);
            case 'T'
                varargout{j-1}=loadMAT(dataPath,psText,subName,trialName);
        end

    end

    % If this point is reached, it's because all data has been loaded.
    return;

end