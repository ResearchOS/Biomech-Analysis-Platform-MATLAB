function [varargout]=getArgPlot(id)

%% PURPOSE: RETURN THE DATA NEEDED FOR THE CURRENT PLOT COMPONENT.

allPlotData=evalin('base','allPlotData');

try
    runInfo=evalin('base','runInfo');
catch
    error('Missing ''runInfo'' from base workspace');
end

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

psStructFcn=runInfo.Fcn.PSStruct;

% Get the actual variable names as stored in file.
inputVars=psStructFcn.InputVariables;
subVars=psStructFcn.InputSubvariables;

for i=1:length(inputVars)

    currVars=inputVars{i};
    currSubvars=subVars{i};

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
        varLevel=piStruct.Level;

        if level<varLevel
            error('Missing subject and/or trial name specification');
        end

        varargout{j-1}=allPlotData.(psText);

        if ~isempty(currSubvars{j})
            varargout{j-1}=eval(['varargout{j-1}' currSubvars{j}]);
        end

    end

    % If this point is reached, it's because all data has been loaded.
    return;

end