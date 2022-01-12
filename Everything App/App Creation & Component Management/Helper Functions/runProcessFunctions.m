function []=runProcessFunctions(groupName,fig)

%% PURPOSE: CALLED IMMEDIATELY AFTER PRESSING THE "RUN GROUP" OR "RUN ALL" BUTTONS
% Inputs:
% groupName: Specifies which group to run. If "Run All" was pressed, it loops over all groups in the callback function. (char)
% fig: The figure variable (handle)

% Outputs:
% None. The data are assigned to the base workspace, and saved to the file.

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

codePath=getappdata(fig,'codePath');
dataPath=getappdata(fig,'dataPath');
projectName=getappdata(fig,'projectName');

% Check for existence of projectStruct
if evalin('base','exist(''projectStruct'',''var'')==1')==1
    projectStruct=evalin('base','projectStruct;'); % Load the projectStruct into the current workspace from the base workspace.
else
    beep;
    warning('Load the data into the projectStruct first!');
    return;
end

% Check for existence of logsheet variable in workspace. If not present, load it. If .mat file not present, throw error.
logPath=getappdata(fig,'logsheetPath');
lastPrdIdx=strfind(logPath,'.');
lastPrdIdx=lastPrdIdx(end);
logVarPath=[logPath(1:lastPrdIdx) 'mat'];
if evalin('base','exist(''logVar'',''var'')==1')==1
    logVar=evalin('base','logVar;'); % Load the logsheet variable
elseif exist(logVarPath,'file')==2
    logVar=load(logVarPath);
    fldName=fieldnames(logVar);
    assert(length(fldName)==1);
    logVar=logVar.(fldName{1});
else
    beep;
    warning(['Missing logsheet .mat file! Should be at: ' logVarPath]);
    return;
end

%% Get the status of every processing function (i.e. whether to run it or not, whether to use its specify trials or the group level)
% Get the processing function names
text=readFcnNames(getappdata(fig,'fcnNamesFilePath'));
[groupNames,lineNums]=getGroupNames(text);
idx=ismember(groupNames,groupName);
lineNum=lineNums(idx); % The line number in the text file of the current group

groupSpecifyTrialsName=[groupName '_Process_SpecifyTrials'];

fcnCount=0;
for i=lineNum+1:length(text)
    
    if isempty(text{i})
        break; % Finished with this group
    end
    
    fcnCount=fcnCount+1;
    a=strsplit(text{i},':');
    fcnNameCell=strsplit(a{1},' ');
    number=fcnNameCell{2}(~isletter(fcnNameCell{2}));
    letter=fcnNameCell{2}(isletter(fcnNameCell{2}));
    fcnNames{fcnCount}=[fcnNameCell{1} '_Process' number]; % All the function names, in order
    argsNames{fcnCount}=[fcnNameCell{1} '_Process' letter]; % All the argument function names, in order
    runAndSpecifyTrialsCell=strsplit(strtrim(a{2}),' ');
    runFuncs(fcnCount)=str2double(runAndSpecifyTrialsCell{1}(end));
    funcSpecifyTrials(fcnCount)=str2double(runAndSpecifyTrialsCell{2}(end));
    funcSpecifyTrialsName{fcnCount}=[fcnNameCell{1} '_Process' number letter '_SpecifyTrials'];
    
    % Get the full path name of the fcnNames (i.e. if in User-Created Functions or Existing Functions folder)
    userFolder=[codePath 'Process_' projectName slash 'User-Created Functions'];
    existFolder=[codePath 'Process_' projectName slash 'Existing Functions'];
    if exist(userFolder,'file')==2 && exist(existFolder,'file')==2
        beep;
        warning(['Function is replicated in ''User-Created Functions'' and ''Existing Functions'' folders: ' fcnNames{fcnCount}]);
        return;
    end
    
    if exist([userFolder slash fcnNames{fcnCount} '.m'],'file')==2
        fcnFolder{fcnCount}=userFolder;
    elseif exist([existFolder slash fcnNames{fcnCount} '.m'],'file')==2
        fcnFolder{fcnCount}=existFolder;
    end
    
end

%% Iterate over all processing functions to get their processing level (project, subject, and trial)
for i=1:length(fcnNames)
    currDir=pwd;
    fcnName=fcnNames{i};
    cd(fcnFolder{i});
    feval(fcnName); % nargin=0 returns the processing level for inputs for each function
    levelsIn{i}=evalin('base','levelIn;'); % The levels of the input arguments
    levelsOut{i}=evalin('base','levelOut;'); % The levels of the output arguments
%     levelsProc{i}=levels.Proc; % The levels to be processed.
    cd(currDir); % Go back to original directory.
    
    if any(~ismember(levelsIn{i},{'P','S','T','PS','PST','ST','PT'})) || any(~ismember(levelsOut{i},{'P','S','T','PS','PST','ST','PT'}))
        beep;
        warning(['Function does not properly specify the processing level: ' fcnName]);
        return;
    end
    
end

%% Iterate over all processing functions to run them.
argsFolder=[codePath 'Process_' projectName slash 'Arguments'];
for i=1:length(fcnNames)
    
    projectStruct=evalin('base','projectStruct;'); % Bring the projectStruct from the base workspace into this one. This incorporates results of any previously finished functions.
    
    fcnName=fcnNames{i};
    argsName=argsNames{i};
    runFunc=runFuncs(i);
    specTrials=funcSpecifyTrials(fcnCount);
    levelIn=levelsIn{i};
    levelOut=levelsOut{i};
%     levelProc=levelsProc{i};
    methodLetter=strsplit(argsName,'_Process');
    methodLetter=methodLetter{2};
    
    if runFunc==0
        disp(['SKIPPING ' fcnName ' BECAUSE IT WAS UNCHECKED IN THE GUI']);
        continue; % If this function shouldn't be run this time, skip it.
    end
    
    % Run the specify trials function, either function or group level.
    if specTrials==1 % Function-level specify trials
        specTrialsFolder=[codePath 'Process_' getappdata(fig,'projectName') slash 'Specify Trials' slash 'Per Function'];
        specTrialsName=funcSpecifyTrialsName{fcnCount};
    else % Group-level specify trials
        specTrialsFolder=[codePath 'Process_' getappdata(fig,'projectName') slash 'Specify Trials' slash 'Per Group'];
        specTrialsName=groupSpecifyTrialsName;
    end
    currDir=pwd;
    cd(specTrialsFolder); % Ensure that the wrong function is not accidentally used
    inclStruct=feval(specTrialsName); % No input arguments
    cd(currDir);
    
    % Run getTrialNames
    trialNames=getTrialNames(inclStruct,logVar,fig,0,projectStruct);
    subNames=fieldnames(trialNames);
    
    projFldNames=fieldnames(projectStruct);
    projFldNames=projFldNames(~ismember(projFldNames,subNames)); % Exclude the subject names from the project field names.    
        
    % Run the processing function
    if ismember(levelIn,'P') || ismember(levelOut,'P') % % Run things at the project, subject, or trial level
        clear projData;
        for fldNum=1:length(projFldNames)
            projData.(projFldNames{fldNum})=projectStruct.(projFldNames{fldNum}); % Project level data only.
        end
        cd(argsFolder);
        [projArgs,~,~]=feval(argsName,'P',projData);
        
        cd(fcnFolder{i});
        if ismember(levelIn,'T') % Provide subject & trial names
            feval(fcnName,projectStruct,methodLetter,trialNames,projData,projArgs); % Saving to file & storing to base workspace is done in the processing functions.
        elseif ismember(levelIn,'S') % Provide subject names only
            feval(fcnName,projectStruct,methodLetter,subNames,projData,projArgs); % Saving to file & storing to base workspace is done in the processing functions.
        else
            feval(fcnName,projectStruct,methodLetter,projData,projArgs); % Saving to file & storing to base workspace is done in the processing functions.
        end
        continue; % Don't iterate through subjects
    end
    
    for sub=1:length(subNames)
        subName=subNames{sub};
        assignin('base','subName',subName);
        currTrials=trialNames.(subName);
        
        if any(ismember(levelIn,'S')) || any(ismember(levelOut,'S')) % Run things at the subject or trial level but NOT at the project level.
            clear subjData;
            subjFldNames=fieldnames(projectStruct.(subName));
            subjFldNames=subjFldNames(~ismember(subjFldNames,trialNames.(subName))); % Exclude the trial names from the subject field names. ISSUE: SPECIFY TRIALS WON'T REMOVE ALL TRIAL NAMES
            for fldNum=1:length(subjFldNames)
                subjData.(subjFldNames{fldNum})=projectStruct.(subName).(subjFldNames{fldNum});
            end
            cd(argsFolder);            
            [~,subjArgs,~]=feval(argsName,'S',subjData);
            
            cd(fcnFolder{i});
            if ismember(levelIn,'T')
                feval(fcnName,methodLetter,currTrials,subjData,subjArgs); % Saving to file & storing to base workspace is done in the processing functions.      
            else
                feval(fcnName,methodLetter,subjData,subjArgs); % Saving to file & storing to base workspace is done in the processing functions.
            end
            continue; % Don't iterate through trials
        end
        
        % Have reached this point because there are only trial level inputs & outputs (& processing) in this function.        
        for trialNum=1:length(currTrials)
            trialName=currTrials{trialNum};
            assignin('base','trialName',trialName);
            trialData=projectStruct.(subName).(trialName); % Nothing to exclude
            
            cd(argsFolder);
            [~,~,trialArgs]=feval(argsName,'T',trialData);
            
            cd(fcnFolder{i});
            feval(fcnName,methodLetter,trialData,trialArgs); % Saving to file & storing to base workspace is done in the processing functions.            
            
        end
        
    end
    
end