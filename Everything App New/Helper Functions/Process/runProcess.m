function [stop, message, emailSubject, e]=runProcess(instUUID,guiInBase)

%% PURPOSE: ACTUALLY RUN THE SPECIFIED FUNCTION

slash=filesep;
e='';

startFcn=tic;

if nargin<2
    guiInBase=false; % By default I don't want to make the user type "false" every time if using without GUI.
end

if guiInBase
    fig=evalin('base','gui;');
end

handles=getappdata(fig,'handles');

[type, abstractID, instanceID] = deText(instUUID);
abstractUUID = genUUID(type, abstractID);

instStruct=loadJSON(instUUID);
absStruct=loadJSON(abstractUUID);

% This loads the linkage matrix for every process struct. Not a problem
% while it's small, but may need to be changed to load just once per run in
% the future.
specifyTrials=getST(instUUID);

fcnName=absStruct.MFileName;
fcnLevel=absStruct.Level;

message = '';
emailSubject = ['Error running process function ' instStruct.UUID ' ' instStruct.Text];
messageProj = ['Date: ' char(datetime('now')) newline 'Subject: ' emailSubject newline 'This function is level: ' fcnLevel newline];

stop = false;
if exist(fcnName,'file')~=2
    message = 'Specified M file does not exist!';
    disp(message);
    stop = true;    
    return;
end

%% CHECK IF ALL UPSTREAM FUNCTIONS & VARIABLES ARE UP TO DATE!

%% NOTE: NEED THE VARIABLES' LEVELS, AND THE FUNCTION'S LEVELS.
Current_Logsheet = getCurrent('Current_Logsheet');
logsheetStruct=loadJSON(Current_Logsheet);
computerID=getComputerID();
logsheetPath=logsheetStruct.LogsheetPath.(computerID);
[logsheetFolder,name]=fileparts(logsheetPath);
logsheetPathMAT=[logsheetFolder slash name '.mat'];
load(logsheetPathMAT,'logVar');

% CD into the current project so that the proper functions are used.
% projectPath=getProjectPath(fig);
% oldPath=cd([projectPath slash 'Process']);
inclStruct=getInclStruct(specifyTrials);
conds = 1;
trialNames=getTrialNames(inclStruct,logVar,conds,logsheetStruct);

% Remove multiple subjects
% remSubNames={}; % Remove nothing
remSubNames={'Lisbon','Baltimore','Mumbai','Busan','Akron','Rabat','Athens','Sacramento','Montreal'};
% remSubNames={'Nairobi','Tokyo','Denver','Oslo','Berlin','Boston','Chicago','London','Paris','Seattle'};

if ~conds
    if any(ismember(remSubNames,fieldnames(trialNames)))
        trialNames=rmfield(trialNames,remSubNames);
    end
else
    if any(ismember(remSubNames,fieldnames(trialNames.Condition)))
        trialNames.Condition=rmfield(trialNames.Condition,remSubNames);
    end
end
subNames=fieldnames(trialNames);

%% Create runInfo and assign it to base workspace.
% Store the info for the process struct
getRunInfo(absStruct,instStruct);

%% Check if all of the input variables are up to date!
inVars = getVarNamesArray(instStruct, 'InputVariables');
for i=1:length(inVars)
    if isempty(inVars{i})
        disp('Missing an input variable!');
        return;
    end
    varStruct = loadJSON(inVars{i});
    [type, abstractID] = deText(varStruct.UUID);
    absVar = genUUID(type, abstractID);
    varAbsStruct = loadJSON(absVar);
    if varStruct.OutOfDate && ~varAbsStruct.IsHardCoded
        disp(['Cannot run this function because input variable ' getName(varStruct.UUID) ' ' varStruct.UUID ' is out of date!']);
        return;
    end
end

%% Run the function!
sendEmail = handles.Process.sendEmailsCheckbox.Value;
if ismember('P',fcnLevel)

    disp(['Running ' fcnName]);

    if sendEmail
        try
            if ismember('T',fcnLevel)
                feval(fcnName,trialNames);
            elseif ismember('S',fcnLevel)
                feval(fcnName,subNames);
            else
                feval(fcnName);
            end
        catch e
            message = messageProj;
            stop = true;
            return;
        end
    else
        if ismember('T',fcnLevel)
            feval(fcnName,trialNames);
        elseif ismember('S',fcnLevel)
            feval(fcnName,subNames);
        else
            feval(fcnName);
        end
    end

end

if ~ismember('P',fcnLevel)
    for sub=1:length(subNames)
        subName=subNames{sub};
        currTrials=fieldnames(trialNames.(subName)); % The list of trial names in the current subject

        messageSubj = [messageProj 'Stopped on subject #' num2str(sub) ': ' subName newline];

        if ismember('S',fcnLevel)

            disp(['Running ' fcnName ' Subject ' subName]);

            if sendEmail
                try
                    if ismember('T',fcnLevel)
                        feval(fcnName,subName,trialNames.(subName)); % projectStruct is an input argument for convenience of viewing the data only
                    else
                        feval(fcnName,subName);
                    end
                catch e
                    message = messageSubj;
                    stop = true;
                    return;
                end
            else
                if ismember('T',fcnLevel)
                    feval(fcnName,subName,trialNames.(subName)); % projectStruct is an input argument for convenience of viewing the data only
                else
                    feval(fcnName,subName);
                end
            end
            continue; % Don't iterate through trials, that's done within the processing function if necessary
        end

        for trialNum=1:length(currTrials)
            trialName=currTrials{trialNum};

            disp(['Running ' fcnName ' Subject ' subName ' Trial ' trialName]);

            for repNum=trialNames.(subName).(trialName)

                if sendEmail
                    try
                        feval(fcnName,subName,trialName,repNum);
                    catch e
                        messageTrial = [messageSubj 'Stopped on trial #' num2str(trialNum) ': ' trialName];
                        message = messageTrial;
                        stop = true;
                        return;
                    end
                else
                    feval(fcnName,subName,trialName,repNum);
                end

            end
        end

    end
end

%% NOTE: AFTER A PROCESS FUNCTION FINISHES RUNNING, NEED TO CHANGE THE 'DATEMODIFIED' METADATA FOR THE VARIABLES' JSON FILES!
modifyVarsDate(instStruct.UUID); % When setting "OutOfDate" to false, this does NOT get recursively applied to up or downstream objects.

%% Remove the completed process function from the queue
queue=getCurrent('Process_Queue');
remQueueIdx=ismember(queue,instStruct.UUID);
queue(remQueueIdx)=[];

setCurrent(queue,'Process_Queue');

evalin('base','clear runInfo'); % Clean up after myself
if isempty(remQueueIdx)
    disp('No data saved, check your process function!');
    return;
end

disp([fcnName ' finished running in ' num2str(round(toc(startFcn),2)) ' seconds']);

if guiInBase
    handles=getappdata(fig,'handles');
    delete(handles.Process.queueUITree.Children(remQueueIdx));
    drawnow;
end

%% Update the digraph
% toggleDigraphCheckboxValueChanged(fig);