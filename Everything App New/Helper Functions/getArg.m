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

uuids = runInfo.Input.VR_ID;
namesInCode = runInfo.Input.NameInCode;
subVars = runInfo.Input.Subvariable;

isHardCoded = runInfo.Input.IsHardCoded;
hardCodedValue = runInfo.Input.HardCodedValue;
varLevel = runInfo.Input.Level;

absNamesInCode = runInfo.Input.AbsNamesInCode;

for i=1:length(absNamesInCode)

    currVars=absNamesInCode{i};    

    if ~isequal(currVars{1},id)
        continue; % Ensure that only the desired getArg ID is used.
    end

    varargout=cell(1,length(currVars)-1); % Initialize output variables.

    for j=2:length(currVars)

        varIdx = ismember(namesInCode,currVars{j});

        if ~any(varIdx)
            continue; % Variable not in the list. Why?
        end

        if isHardCoded(varIdx)
            varargout{j-1} = hardCodedValue{j-1};
            continue;
        end

        % 3. If dynamic, find the proper file by looking at its text,
        % level, and subName/trialName/repNum values.
        uuid=uuids{varIdx};
        varLevel=varLevel{varIdx};

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

        if ~isempty(subVars{j-1}) && ~isequal(subVars{j-1},'NULL')
            varargout{j-1}=eval(['varargout{j-1}' subVars{j-1}]);
        end

    end

    % If this point is reached, it's because all data has been loaded.
    return;

end