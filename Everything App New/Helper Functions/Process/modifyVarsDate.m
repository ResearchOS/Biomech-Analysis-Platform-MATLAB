function [remQueueIdx]=modifyVarsDate(processText)

%% PURPOSE: SET THE DATEMODIFIED PROPERTY OF THE OUTPUT VARIABLES OF A PROCESS FUNCTION TO NOW.

try
    runInfo=evalin('base','runInfo');
catch
    error('Missing ''runInfo'' from base workspace');
end

date=datetime('now');

if ~isfield(runInfo,'SetArgIDsUsed')
    return; % setArg was never ran, so no variables were modified.
end

ids=runInfo.SetArgIDsUsed; % This ensures that if there's any setArg ID's that are unused for some reason, they're not updated.

processPath=getClassFilePath(processText,'Process');
processStruct=loadJSON(processPath);

processStruct.DateModified=date;
processStruct.OutOfDate=false;
processStruct.DateLastRan=date;
writeJSON(processPath,processStruct);

outputVars=processStruct.OutputVariables;

for i=1:length(outputVars)

    currVars=outputVars{i};

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

%% Remove the completed process function from the queue
projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);

queue=projectSettings.ProcessQueue;
remQueueIdx=ismember(queue,processStruct.Text);
queue(remQueueIdx)=[];

projectSettings.ProcessQueue=queue;
writeJSON(projectSettingsFile,projectSettings);