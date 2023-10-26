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
varLevels = runInfo.Input.Level;

absNamesInCode = runInfo.Input.AbsNamesInCode;

for i=1:length(absNamesInCode)

    currVars=absNamesInCode{i};    

    if ~isequal(currVars{1},id)
        continue; % Ensure that only the desired getArg ID is used.
    end

    currVars(1) = []; % Remove the ID

    varargout=cell(1,length(currVars)); % Initialize output variables.

    % Ensure the ability to run a function with only a subset of variables
    % initialized.
    currVars(~ismember(currVars,namesInCode)) = []; % Remove vars (from list in abstract) that are not assigned in this instance yet.

    % Isolate only the vars in this getArg ID (that have been implemented)
    % currVarsIdx = ismember(namesInCode,currVars);
    currVarsIdx = makeSameOrder(currVars, namesInCode);
    currNamesInCode = namesInCode(currVarsIdx);
    currUUIDs = uuids(currVarsIdx);
    currSubVars = subVars(currVarsIdx);

    currIsHardCoded = isHardCoded(currVarsIdx);
    currHardCodedValue = hardCodedValue(currVarsIdx);
    currVarLevels = varLevels(currVarsIdx);    

    for j=1:length(currVars)

        % varIdx = ismember(currNamesInCode,currVars{j});        

        % if ~any(varIdx)
        %     continue; % Variable not in the list. Why?
        % end

        if currIsHardCoded(j)
            varargout{j} = currHardCodedValue{j};
            continue;
        end

        % 3. If dynamic, find the proper file by looking at its text,
        % level, and subName/trialName/repNum values.
        uuid=currUUIDs{j};
        varLevel=currVarLevels{j};

        if level<varLevel
            error('Missing subject and/or trial name specification');
        end

        % 4. Load the dynamic variable.
        try
            switch varLevel
                case 'P'
                    subName = '';
                    trialName = '';
                    varargout{j}=loadMAT(dataPath,uuid);
                case 'S'
                    trialName = '';
                    varargout{j}=loadMAT(dataPath,uuid,subName);
                case 'T'
                    varargout{j}=loadMAT(dataPath,uuid,subName,trialName);
            end
        catch e
            if contains(e.message,'Unable to find file or directory')
                disp(['Missing variable: ' uuid ' (' getName(uuid) ' Subject: ' subName ' Trial: ' trialName]);
                varargout{j} = missing;
                continue;
            end
        end

        if ~isempty(currSubVars{j}) && ~isequal(currSubVars{j},'NULL')
            varargout{j}=eval(['varargout{j}' currSubVars{j}]);
        end

    end

    % If this point is reached, it's because all data has been loaded.
    return;

end