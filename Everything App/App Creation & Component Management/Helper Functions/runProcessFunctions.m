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
% dataPath=getappdata(fig,'dataPath');
projectName=getappdata(fig,'projectName');

% Check for existence of projectStruct
if evalin('base','exist(''projectStruct'',''var'')==1')==0
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
    argsNames{fcnCount}=[fcnNameCell{1} '_Process' number letter]; % All the argument function names, in order
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

%% Check existence of all input arguments functions
argsFolder=[codePath 'Process_' projectName slash 'Arguments'];
currDir=cd(argsFolder);
for i=1:length(fcnNames)
    
    if exist([argsNames{i} '.m'],'file')~=2
        beep;
        warning(['Input Argument Function Does Not Exist: ' argsNames{i}]);
        return;
    end
    
end
cd(currDir);

%% Iterate over all processing functions to get their processing level (project, subject, and trial)
for i=1:length(fcnNames)    
    fcnName=fcnNames{i};
    cd(fcnFolder{i});
    feval(fcnName); % nargin=0 returns the processing level for inputs for each function
    levels=evalin('base','levels;'); % The levels of the input arguments  
    
    if any(~ismember(levels{i},{'P','S','T','PS','PST','ST','PT'}))
        beep;
        warning(['Function does not properly specify the processing level: ' fcnName]);
        return;
    end
    
end

cd(currDir); % Go back to original directory.

%% Iterate over all processing functions in the group to run them.
for i=1:length(fcnNames)
    
    % Bring the projectStruct from the base workspace into this one. Doing this for each function incorporates results of any previously finished functions.
    projectStruct=evalin('base','projectStruct;');
    
    fcnName=fcnNames{i};
    argsName=argsNames{i};
    runFunc=runFuncs(i);
    specTrials=funcSpecifyTrials(fcnCount);
    currLevels=levels{i};
    methodLetter=strsplit(argsName,'_Process');
    methodLetter=methodLetter{2}(isletter(methodLetter{2}));
    assignin('base','methodLetter',methodLetter); % Send the method letter to the base workspace
    
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
    cd(specTrialsFolder); % Ensure that the wrong function is not accidentally used
    inclStruct=feval(specTrialsName); % No input arguments
    cd(currDir);
    
    % Run getTrialNames
    trialNames=getTrialNames(inclStruct,logVar,fig,0,projectStruct);
    subNames=fieldnames(trialNames);
    
    % Run the processing function
    if any(ismember(currLevels,'P'))
        if any(ismember(currLevels,'T'))
            feval(fcnName,projectStruct,trialNames); % projectStruct is an input argument for convenience of viewing the data only    
        elseif any(ismember(currLevels,'S'))
            feval(fcnName,projectStruct,fieldnames(trialNames));
        else
            feval(fcnName,projectStruct);
        end
        continue; % Don't iterate through subjects, that's done within the processing function if necessary
    end
    
    for sub=1:length(subNames)
        subName=subNames{sub};
        currTrials=trialNames.(subName); % The list of trial names in the current subject
        
        if any(ismember(currLevels,'S'))
            if any(ismember(currLevels,'T'))
                feval(fcnName,projectStruct,subName,currTrials); % projectStruct is an input argument for convenience of viewing the data only
            else
               feval(fcnName,projectStruct,subName); 
            end
            continue; % Don't iterate through trials, that's done within the processing function if necessary
        end
        
        for trialNum=1:length(currTrials)
            trialName=currTrials{trialNum};
            feval(fcnName,projectStruct,subName,trialName); % projectStruct is an input argument for convenience of viewing the data only            
        end        
        
    end    
    
end