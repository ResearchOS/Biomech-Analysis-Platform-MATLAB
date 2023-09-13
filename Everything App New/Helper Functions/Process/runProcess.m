function [stop, message, emailSubject, e]=runProcess(instUUID,guiInBase)

%% PURPOSE: ACTUALLY RUN THE SPECIFIED FUNCTION

global conn;

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

fcnName=absStruct.ExecFileName;
fcnLevel=absStruct.Level;

currDate = char(datetime('now'));

message = '';
emailSubject = ['Error running process function ' instStruct.UUID ' ' instStruct.Name];
messageProj = ['Date: ' currDate newline 'Subject: ' emailSubject newline 'This function is level: ' fcnLevel newline];

stop = false;
if exist(fcnName,'file')~=2
    message = 'Specified M file does not exist!';
    disp(message);
    stop = true;    
    return;
end

G = getappdata(fig,'digraph');
if isempty(G)
    G = refreshDigraph(fig);
end

%% CHECK IF ALL UPSTREAM FUNCTIONS & VARIABLES ARE UP TO DATE!
% [~,deps] = getDeps(G,'up',instUUID);
% sqlquery = ['SELECT UUID, OutOfDate FROM Process_Instances'];
% t = fetch(conn, sqlquery);
% t = table2MyStruct(t);
% instUUIDidx = ismember(t.UUID,instUUID);
% t.UUID(instUUIDidx) = []; % Remove the PR from the check for dependencies.
% t.OutOfDate(instUUIDidx) = [];
% depIdx = ismember(t.UUID,deps);
% t.UUID(~depIdx) = [];
% t.OutOfDate(~depIdx) = [];
% outOfDateIdx = ismember(t.OutOfDate,1);
% if any(outOfDateIdx)
%     outOfDateDeps = t.UUID(outOfDateIdx);
%     a = questdlg('There are dependent PR out of date. Add them to queue?','Add deps to queue?','Yes','No','Cancel','Yes');
%     if isequal(a,'Yes')
%         addToQueueButtonPushed(fig,outOfDateDeps);
%     end
%     stop = true;    
% end

% Only need to check the input variables to this function. If a var is hard
% coded and not up to date, that's ok. If is hard coded = 0 and not up to
% date, suggest to the user that they add the pre-req PR's to the queue.
% sqlquery = ['SELECT VR_ID FROM VR_PR WHERE PR_ID = ''' instUUID ''';'];
% t = fetch(conn, sqlquery);
% t = table2MyStruct(t);
% varNames = t.VR_ID;
% varStr = getCondStr(varNames);
% sqlquery = ['SELECT UUID, Abstract_UUID, OutOfDate FROM Variables_Instances WHERE UUID IN ' varStr];
% t = fetch(conn, sqlquery);
% tInst = table2MyStruct(t);
% 
% if ~iscell(tInst.Abstract_UUID)
%     tInst.UUID = {tInst.UUID};
%     tInst.Abstract_UUID = {tInst.Abstract_UUID};
% end
% 
% absVars = unique(tInst.Abstract_UUID,'stable');
% absVarStr = getCondStr(absVars);
% sqlquery = ['SELECT UUID, IsHardCoded FROM Variables_Abstract WHERE UUID IN ' absVarStr];
% t = fetch(conn, sqlquery);
% tAbs = table2MyStruct(t);
% 
% if ~iscell(tAbs.UUID)
%     tAbs.UUID = {tAbs.UUID};
% end
% 
% hardCodedIdxAbs = ismember(tAbs.IsHardCoded,1);
% hardCodedUUID = tAbs.UUID(hardCodedIdxAbs);
% hardCodedIdxInst = contains(tInst.UUID, hardCodedUUID);
% outOfDateIdx = tInst.OutOfDate==1 & ~hardCodedIdxInst;
% hardCodedOutOfDate = tInst.UUID(hardCodedIdxInst & tInst.OutOfDate==1);
% if any(outOfDateIdx)
%     outOfDateInputs = tInst.UUID(outOfDateIdx);
%     outOfDateStr = getCondStr(outOfDateInputs);
%     sqlquery = ['SELECT PR_ID FROM PR_VR WHERE PR_ID = ''' instUUID ''' AND VR_ID IN ' outOfDateStr];
%     t = fetch(conn, sqlquery);
%     t = table2MyStruct(t);
%     a = questdlg('There are input variables out of date. Add their PR to queue?',' Add deps to queue?','Yes','No','Cancel','Yes');
%     if isequal(a,'Yes')
%         addToQueueButtonPushed(fig, t.PR_ID);
%     end
%     stop = true;    
% end

if stop
    return; % Because something is out of date.
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
conds = 0;
trialNames=getTrialNames(inclStruct,logVar,conds,logsheetStruct);

% Remove multiple subjects
% remSubNames={}; % Remove nothing
% remSubNames={'Lisbon','Baltimore','Mumbai','Busan','Akron','Rabat','Athens','Sacramento','Montreal'};
remSubNames={'Nairobi','Tokyo','Denver','Oslo','Berlin','Boston','Chicago','London','Paris','Seattle'};

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
% Store the info for getArg and setArg
getRunInfo(absStruct,instStruct);

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

%% Update the hard-coded out of date input variables to be up to date.
% hardCodedStr = getCondStr(hardCodedOutOfDate);
% currDate = char(datetime('now'));
% sqlquery = ['UPDATE Variables_Instances SET OutOfDate = 0, Date_Modified = ''' currDate ''' WHERE UUID IN ' hardCodedStr];
% if ~isempty(hardCodedOutOfDate)
%     execute(conn, sqlquery);
% end

%% Update out of date for PR & outputs. Don't propagate beyond the outputs of this PR.
setPR_VROutOfDate(fig, instUUID, false, false);

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
queueNode = getNode(handles.Process.queueUITree, instStruct.UUID);
delete(queueNode);
drawnow;

setCurrent(queue,'Process_Queue');
refreshDigraph(fig);

evalin('base','clear runInfo'); % Clean up after myself
if isempty(remQueueIdx)
    disp('No data saved, check your process function!');
    return;
end

disp([fcnName ' finished running in ' num2str(round(toc(startFcn),2)) ' seconds']);