function []=modifyVarsDate(processText)

%% PURPOSE: SET THE DATEMODIFIED PROPERTY OF THE OUTPUT VARIABLES OF A PROCESS FUNCTION TO NOW.

try
    runInfo=evalin('base','runInfo');
catch
    error('Missing ''runInfo'' from base workspace');
end

date=datetime('now');

ids=runInfo.setArgIDsUsed; % This ensures that if there's any setArg ID's that are unused for some reason, they're not updated.

processPath=getClassFilePath(processText,'Process');
processStruct=loadJSON(processPath);

outputVars=processStruct.OutputVariables;

for i=1:length(outputVars)

    currVars=outputVars{i};

    if ~ismember(currVars{1},ids)
        continue; % This setArg ID was not used in the actual process function.
    end

    for j=2:length(currVars)

        varText=currVars{j};

        saveClass('Variable', varText, date); % Updates the date modified.

    end

end