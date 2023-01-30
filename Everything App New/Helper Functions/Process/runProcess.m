function []=runProcess(psText,guiInBase)

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

piText=getPITextFromPS(psText);

filePath=getClassFilePath_PS(psText, 'Process');
filePathPI=getClassFilePath(piText, 'Process');

processStructPS=loadJSON(filePath);
processStructPI=loadJSON(filePathPI);

specifyTrials=processStructPS.SpecifyTrials;

fcnName=processStructPI.MFileName;

%% NOTE: NEED THE VARIABLES' LEVELS, AND THE FUNCTION'S LEVELS.
level=processStructPI.Level;

logNode=handles.Import.allLogsheetsUITree.SelectedNodes;
logStructPath=getClassFilePath(logNode);
logsheetStruct=loadJSON(logStructPath);
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
subNames=fieldnames(trialNames);

%% Create runInfo and assign it to base workspace.
% Store the info for the process struct
getRunInfo(processStructPI,processStructPS);

%% NOTE: AFTER A PROCESS FUNCTION FINISHES RUNNING, NEED TO CHANGE THE 'DATEMODIFIED' METADATA FOR THE VARIABLES' JSON FILES!

%% Run the function!
if ismember('P',level)

    disp(['Running ' fcnName]);

    if ismember('T',level)
        feval(fcnName,trialNames);
    elseif ismember('S',level)
        feval(fcnName,subNames);
    else
        feval(fcnName);
    end

end

if ~ismember('P',level)
    for sub=1:length(subNames)
        subName=subNames{sub};
        currTrials=fieldnames(trialNames.(subName)); % The list of trial names in the current subject

        if ismember('S',level)

            disp(['Running ' fcnName ' Subject ' subName]);

            if ismember('T',level)
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

remQueueIdx=modifyVarsDate(processStructPS.Text);
disp([fcnName ' finished running in ' num2str(round(toc(startFcn),2)) ' seconds']);

evalin('base','clear runInfo'); % Clean up after myself

if guiInBase
    handles=getappdata(fig,'handles');
    delete(handles.Process.queueUITree.Children(remQueueIdx));
end