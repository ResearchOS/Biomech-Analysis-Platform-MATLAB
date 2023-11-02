function [stop, message, emailSubject, e]=runProcess(instUUID,guiInBase)

%% PURPOSE: ACTUALLY RUN THE SPECIFIED FUNCTION

slash=filesep;
e='';
stop = false;
% message = '';
emailSubject = 'Biomech OS Error';

startFcn=tic;

if nargin<2
    guiInBase=false; % By default I don't want to make the user type "false" every time if using without GUI.
end

if guiInBase
    try
        headless = false;
        fig=evalin('base','gui;');
    catch
        headless = true;
    end
end

if ~headless
    handles=getappdata(fig,'handles');
end

[type, abstractID, instanceID] = deText(instUUID);
abstractUUID = genUUID(type, abstractID);

instStruct=loadJSON(instUUID);
absStruct=loadJSON(abstractUUID);

% This loads the linkage matrix for every process struct. Not a problem
% while it's small, but may need to be changed to load just once per run in
% the future.
specifyTrials=getST(instUUID);

if isempty(specifyTrials)
    stop = true;
    message = ['No specify trials found for this processing function: ' getName(instUUID)];
    disp(message);
    return;
end

fcnName=absStruct.ExecFileName;
fcnLevel=absStruct.Level;

currDate = char(datetime('now'));

message = '';
emailSubject = ['Error running process function ' instStruct.UUID ' ' instStruct.Name];
messageProj = ['Date: ' currDate newline 'Subject: ' emailSubject newline 'This function is level: ' fcnLevel newline];

if exist(fcnName,'file')~=2
    message = 'Specified M file does not exist!';
    disp(message);
    stop = true;    
    return;
end

if ~headless
    G = getappdata(fig,'digraph');
    if isempty(G)
        G = refreshDigraph(fig);
    end
end

%% NOTE: NEED THE VARIABLES' LEVELS, AND THE FUNCTION'S LEVELS.
Current_Logsheet = getCurrent('Current_Logsheet');
logsheetStruct=loadJSON(Current_Logsheet);
computerID=getComputerID();
logsheetPath=logsheetStruct.Logsheet_Path.(computerID);
[logsheetFolder,name]=fileparts(logsheetPath);
logsheetPathMAT=[logsheetFolder slash name '.mat'];
load(logsheetPathMAT,'logVar');

% CD into the current project so that the proper functions are used.
% projectPath=getProjectPath(fig);
% oldPath=cd([projectPath slash 'Process']);
inclStruct=getInclStruct(specifyTrials);
conds = absStruct.UsesConds;
trialNames=getTrialNames(inclStruct,logVar,conds,logsheetStruct);

% Remove multiple subjects
remSubNames={}; % Remove nothing
% remSubNames={'Lisbon','Baltimore','Mumbai','Busan','Akron','Rabat','Athens','Sacramento','Montreal','Nairobi','Tokyo','Berlin','Denver','Oslo','Boston','Seattle','Chicago','Paris'};
% remSubNames={'Lisbon','Baltimore','Mumbai','Busan','Akron','Rabat','Athens','Sacramento','Montreal'};
% remSubNames={'Nairobi','Tokyo','Denver','Oslo','Berlin','Boston','Chicago','London','Paris','Seattle','Lisbon','Baltimore','Mumbai','Busan'};
% remSubNames={'Nairobi','Tokyo','Denver','Oslo','Berlin','Boston','Chicago','London','Paris','Seattle'};
% remSubNames = {'Apple_V4','Apple_V5','Apple_V7'};

subNames=fieldnames(trialNames);
remSubNames = remSubNames(ismember(remSubNames,subNames)); % Don't remove what doesn't exist.
if exist('remSubNames','var') && ~isempty(remSubNames)
    if ~conds
        if any(ismember(remSubNames,fieldnames(trialNames)))
            trialNames=rmfield(trialNames,remSubNames);
        end        
        subNames=fieldnames(trialNames);
    else
        if any(ismember(remSubNames,fieldnames(trialNames.Condition)))
            trialNames.Condition=rmfield(trialNames.Condition,remSubNames);
        end
        subNames=fieldnames(trialNames.Condition);
    end
end

%% Create runInfo and assign it to base workspace.
% Store the info for getArg and setArg
[runInfo, runInfoStop] = getRunInfo(absStruct,instStruct);
if runInfoStop
    stop = true;
    return;
end

%% Run the function!
if ~headless
    sendEmail = handles.Process.sendEmailsCheckbox.Value;
else
    sendEmail = false; % Hard coded for now. Later this should be in SQL.
end
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

%% Update the hard-coded out of date input variables to be up to date.
% hardCodedStr = getCondStr(hardCodedOutOfDate);
% currDate = char(datetime('now'));
% sqlquery = ['UPDATE Variables_Instances SET OutOfDate = 0, Date_Modified = ''' currDate ''' WHERE UUID IN ' hardCodedStr];
% if ~isempty(hardCodedOutOfDate)
%     execute(conn, sqlquery);
% end

%% Update out of date for PR & outputs. Don't propagate beyond the outputs of this PR.
if headless
    fig = '';
end
setObjsOutOfDate(fig, instUUID, false, false);

%% NOTE: AFTER A PROCESS FUNCTION FINISHES RUNNING, NEED TO CHANGE THE 'DATEMODIFIED' METADATA FOR THE VARIABLES' JSON FILES!
modifyVarsDate(instStruct.UUID); % When setting "OutOfDate" to false, this does NOT get recursively applied to up or downstream objects.

%% Remove the completed process function from the queue.
% No need to update the digraph because obviously the digraph is not being
% shown, and will be updated when shown next.
queue=getCurrent('Process_Queue');
if ~iscell(queue)
    queue = {queue};
end
remQueueIdx=ismember(queue,instStruct.UUID);
queue(remQueueIdx)=[];
setCurrent(queue,'Process_Queue');
fillQueueUITree(fig);

if ~headless
    queueNode = getNode(handles.Process.queueUITree, instStruct.UUID);
    delete(queueNode);
    drawnow;
    refreshDigraph(fig);
end

evalin('base','clear runInfo'); % Clean up after myself
if isempty(remQueueIdx)
    disp('No data saved, check your process function!');
    return;
end

disp([fcnName ' finished running in ' num2str(round(toc(startFcn),2)) ' seconds']);