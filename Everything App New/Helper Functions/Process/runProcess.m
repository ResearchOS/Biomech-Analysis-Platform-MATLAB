function []=runProcess(instUUID,guiInBase)

%% PURPOSE: ACTUALLY RUN THE SPECIFIED FUNCTION

slash=filesep;

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

if exist(fcnName,'file')~=2
    error('Specified M file does not exist!');
end

%% NOTE: NEED THE VARIABLES' LEVELS, AND THE FUNCTION'S LEVELS.
fcnLevel=absStruct.Level;

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
trialNames=getTrialNames(inclStruct,logVar,0,logsheetStruct);

% Remove multiple subjects
% remSubNames={'Lisbon','Baltimore','Mumbai','Busan','Akron','Rabat','Athens','Sacramento','Montreal'};
% remSubNames={'Nairobi','Tokyo','Denver','Oslo','Berlin','Boston','Chicago','London','Paris','Seattle'};

% Remove all but one subject
% remSubNames=fieldnames(trialNames);
% idx=ismember(remSubNames,'Busan');
% remSubNames(idx)=[];

% trialNames=rmfield(trialNames,remSubNames);
subNames=fieldnames(trialNames);

%% Create runInfo and assign it to base workspace.
% Store the info for the process struct
getRunInfo(absStruct,instStruct);

%% Run the function!
if ismember('P',fcnLevel)

    disp(['Running ' fcnName]);

    if ismember('T',fcnLevel)
        feval(fcnName,trialNames);
    elseif ismember('S',fcnLevel)
        feval(fcnName,subNames);
    else
        feval(fcnName);
    end

end

if ~ismember('P',fcnLevel)
    for sub=1:length(subNames)
        subName=subNames{sub};
        currTrials=fieldnames(trialNames.(subName)); % The list of trial names in the current subject

        if ismember('S',fcnLevel)

            disp(['Running ' fcnName ' Subject ' subName]);

            if ismember('T',fcnLevel)
                feval(fcnName,subName,trialNames.(subName)); % projectStruct is an input argument for convenience of viewing the data only
            else
                feval(fcnName,subName);
            end
            continue; % Don't iterate through trials, that's done within the processing function if necessary
        end

        for trialNum=1:length(currTrials)
            trialName=currTrials{trialNum};

            disp(['Running ' fcnName ' Subject ' subName ' Trial ' trialName]);

            for repNum=trialNames.(subName).(trialName)

                feval(fcnName,subName,trialName,repNum); % projectStruct is an input argument for convenience of viewing the data only

            end
        end

    end
end

%% NOTE: AFTER A PROCESS FUNCTION FINISHES RUNNING, NEED TO CHANGE THE 'DATEMODIFIED' METADATA FOR THE VARIABLES' JSON FILES!
modifyVarsDate(instStruct.UUID);

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