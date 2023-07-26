function []=modifyVarsDate(uuid)

%% PURPOSE: SET THE DATEMODIFIED PROPERTY OF THE OUTPUT VARIABLES OF A PROCESS FUNCTION TO NOW.
% If a Process function, iterates over all output variables to give them a
% new saved date.
% If a Variable, saves that Variable with a new saved date.

date=datetime('now');

struct=loadJSON(uuid);

struct.DateModified=date;
struct.OutOfDate=false;
struct.DateLastRan=date;
writeJSON(getJSONPath(struct),struct); % Already overwrites the date saved.

% Only run the below code if there are output variables, i.e. if this is a
% Process function.
[type] = deText(uuid);
if ~isequal(type,'PR')
    return;
end

try
    runInfo=evalin('base','runInfo');
catch
    error('Missing ''runInfo'' from base workspace');
end

if ~isfield(runInfo,'SetArgIDsUsed')
    return; % setArg was never ran, so no variables were modified.
end

ids=runInfo.SetArgIDsUsed; % This ensures that if there's any setArg ID's that are unused for some reason, they're not updated.

outputVars=struct.OutputVariables;

%% Update each of the output variables.
for i=1:length(outputVars)

    currVars=outputVars{i};

    % The first index is the setArg ID, then the rest are the output
    % variable names.
    if ~ismember(currVars{1},ids)
        continue; % This setArg ID was not used in the actual process function.
    end

    for j=2:length(currVars)

        varUUID=currVars{j};        
        varStruct=loadJSON(varUUID);
        varStruct.OutOfDate = false;        
        
        writeJSON(getJSONPath(varStruct), varStruct);

    end

end