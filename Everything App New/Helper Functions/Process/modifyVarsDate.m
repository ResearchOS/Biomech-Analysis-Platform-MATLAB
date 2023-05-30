function []=modifyVarsDate(text, class)

%% PURPOSE: SET THE DATEMODIFIED PROPERTY OF THE OUTPUT VARIABLES OF A PROCESS FUNCTION TO NOW.
% If a Process function, iterates over all output variables to give them a
% new saved date.
% If a Variable, saves that Variable with a new saved date.

if nargin==1
    class='Process';
end

date=datetime('now');

structPath=getClassFilePath(text,class);
struct=loadJSON(structPath);

struct.DateModified=date;
struct.OutOfDate=false;
struct.DateLastRan=date;
writeJSON(structPath,struct); % Already overwrites the date saved.

if ~isequal(class,'Process')
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

for i=1:length(outputVars)

    currVars=outputVars{i};

    % The first index is the setArg ID, then the rest are the output
    % variable names.
    if ~ismember(currVars{1},ids)
        continue; % This setArg ID was not used in the actual process function.
    end

    for j=2:length(currVars)

        varText=currVars{j};
        varPath=getClassFilePath(varText,'Variable');
        varStruct=loadJSON(varPath);

        saveClass_PS('Variable', varStruct, date); % Updates the date modified.

    end

end