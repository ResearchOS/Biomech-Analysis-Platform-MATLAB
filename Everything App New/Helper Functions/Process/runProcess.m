function []=runProcess(psText,guiInBase)

%% PURPOSE: ACTUALLY RUN THE SPECIFIED FUNCTION

slash=filesep;

startFcn=tic;

if nargin<2
    guiInBase=false; % By default I don't want to make the user type false every time if using without GUI.
end

if guiInBase
    fig=evalin('base','gui;');
end

piText=getPITextFromPS(psText);

filePath=getClassFilePath_PS(psText, 'Process', fig);
filePathPI=getClassFilePath(piText, 'Process', fig);

processStructPS=loadJSON(filePath);
processStructPI=loadJSON(filePathPI);

specifyTrials=processStructPS.SpecifyTrials;

fcnName=processStructPI.MFileName;

%% NOTE: NEED THE VARIABLES' LEVELS, AND THE FUNCTION'S LEVELS.
level=processStructPI.Level;

% CD into the current project so that the proper functions are used.
% projectPath=getProjectPath(fig);
% oldPath=cd([projectPath slash 'Process']);
% inclStruct=getInclStruct(fig,specifyTrials);
% trialNames=getTrialNames(inclStruct,logVar,fig,0);
% subNames=fieldnames(trialNames);

%% Create runInfo and assign it to base workspace.
% Store the info for the process struct
getRunInfo(processStructPI,processStructPS,fig);

%% Run the function!
if ismember('P',level)

    disp(['Running ' fcnName]);

    if ismember('T',level)
        feval(fcnName,projectStruct,trialNames);
    elseif ismember('S',level)
        feval(fcnName,projectStruct,subNames);
    else
        feval(fcnName,projectStruct);
    end
    disp([fcnName ' finished running in ' num2str(round(toc(startFcn),2)) ' seconds']);
    return;
end

for sub=1:length(subNames)
    subName=subNames{sub};
    currTrials=fieldnames(trialNames.(subName)); % The list of trial names in the current subject

    if ismember('S',level)

        disp(['Running ' fcnName ' Subject ' subName]);

        if ismember('T',level)
            feval(fcnName,projectStruct,subName,trialNames.(subName)); % projectStruct is an input argument for convenience of viewing the data only
        else
            feval(fcnName,projectStruct,subName);
        end
        if sub==length(subNames)
            disp([fcnName ' finished running in ' num2str(round(toc(startFcn),2)) ' seconds']);
        end
        continue; % Don't iterate through trials, that's done within the processing function if necessary
    end

    for trialNum=1:length(currTrials)
        trialName=currTrials{trialNum};

        disp(['Running ' fcnName ' Subject ' subName ' Trial ' trialName]);

        for repNum=trialNames.(subName).(trialName)

            if ~isImport
                feval(fcnName,projectStruct,subName,trialName,repNum); % projectStruct is an input argument for convenience of viewing the data only
            else
                filePath=[dataPath subName slash trialName '_' subName '_' projectName '.c3d'];
                feval(fcnName,filePath,projectStruct,subName,trialName,repNum);
            end

        end
    end

    disp([fcnName ' finished running in ' num2str(round(toc(startFcn),2)) ' seconds']);

end

cd(oldPath);

evalin('base','clear runInfo'); % Clean up after myself