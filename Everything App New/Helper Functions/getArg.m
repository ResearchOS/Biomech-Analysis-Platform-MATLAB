function [varargout]=getArg(id,subName,trialName,repNum)

%% PURPOSE: RETURN INPUT ARGUMENTS TO A PROCESSING FUNCTION

%% Plotting or processing?
try
    allPlotData=evalin('base','allPlotData');
    varargout=getArgPlot(id);
    return;
catch
    try
        runInfo=evalin('base','runInfo');
    catch
        error('Missing ''runInfo'' from base workspace');
    end
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

instStructFcn=runInfo.Fcn.InstStruct;

% Get the actual variable names as stored in file.
inputVars=instStructFcn.InputVariables;
subVars=instStructFcn.InputSubvariables;

for i=1:length(inputVars)

    currVars=inputVars{i};
    currSubvars=subVars{i};

    if ~isequal(currVars{1},id)
        continue; % Ensure that only the desired getArg ID is used.
    end

    varargout=cell(1,length(currVars)-1); % Initialize output variables.

    for j=2:length(currVars)

        instStruct=runInfo.Var.Input(i).InstStruct{j-1};
        absStruct=runInfo.Var.Input(i).AbsStruct{j-1};

        % 1. If hard-coded, use value stored in struct and continue.
        if absStruct.IsHardCoded
            varargout{j-1}=instStruct.HardCodedValue;
            continue;
        end

        % 3. If dynamic, find the proper file by looking at its text,
        % level, and subName/trialName/repNum values.
        uuid=instStruct.UUID;
        varLevel=absStruct.Level;

        if level<varLevel
            error('Missing subject and/or trial name specification');
        end

        % 4. Load the dynamic variable.
        switch varLevel
            case 'P'
                varargout{j-1}=loadMAT(dataPath,uuid);
            case 'S'
                varargout{j-1}=loadMAT(dataPath,uuid,subName);
            case 'T'
                varargout{j-1}=loadMAT(dataPath,uuid,subName,trialName);
        end

        if ~isempty(currSubvars{j})
            varargout{j-1}=eval(['varargout{j-1}' currSubvars{j}]);
        end

    end

    % If this point is reached, it's because all data has been loaded.
    return;

end