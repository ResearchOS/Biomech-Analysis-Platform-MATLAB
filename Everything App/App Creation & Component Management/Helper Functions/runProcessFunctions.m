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
    levels=feval(fcnName); % nargin=0 returns the processing level for inputs for each function
    levelsIn{i}=levels.In; % The levels of the input arguments
    levelsOut{i}=levels.Out; % The levels of the output arguments
    levelsProc{i}=levels.Proc; % The levels to be processed.
    cd(currDir); % Go back to original directory.
    
    if ~ismember(levels{i},{'P','S','T','PS','PST','ST','PT'})
        beep;
        warning(['Function does not properly specify the processing level: ' fcnName]);
        return;
    end
    
end

%% Iterate over all processing functions to run them.
argsFolder=[codePath 'Process_' projectName slash 'Arguments'];
for i=1:length(fcnNames)
    
    fcnName=fcnNames{i};
    argsName=argsNames{i};
    runFunc=runFuncs(i);
    specTrials=funcSpecifyTrials(fcnCount);
    levelIn=levelsIn{i};
    levelOut=levelsOut{i};
    levelProc=levelsProc{i};
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
    if ismember(levelIn,'P') % Get the project level input arguments
        clear projData;
        for fldNum=1:length(projFldNames)
            projData.(projFldNames{fldNum})=projectStruct.(projFldNames{fldNum}); % Project level data only.
        end
        cd(argsFolder);
        [projArgs,~,~]=feval(argsName,level,projData);
    end
    
    if ismember(levelProc,'P') % Processing is done at project, subject, and/or trial level
        % Isolate project level data only.
        cd(fcnFolder{i});
        argsOut=feval(fcnName,methodLetter,projData,projArgs);
        continue; % No need to iterate through subjects & trials
    end
    
    for sub=1:length(subNames)
        subName=subNames{sub};
        
        if ismember(levelIn,'S') % Get the subject level input arguments
            clear subjData;
            subjFldNames=fieldnames(projectStruct.(subName));
            subjFldNames=subjFldNames(~ismember(subjFldNames,trialNames.(subName))); % Exclude the trial names from the subject field names. ISSUE: SPECIFY TRIALS WON'T REMOVE ALL TRIAL NAMES
            for fldNum=1:length(subjFldNames)
                subjData.(subjFldNames{fldNum})=projectStruct.(subName).(subjFldNames{fldNum});
            end
            cd(argsFolder);
            [~,subjArgs,~]=feval(argsName,level,subjData,subName);
        end
        
        if ismember(levelProc,'S') % Processing is done at the subject and/or trial level.
            cd(fcnFolder{i});
            if isequal(levelIn,'S') && ismember(levelProc,'S') % Subject level inputs & processing only
                argsOut=feval(fcnName,methodLetter,subjData,subjArgs);
            elseif all(ismember(levelIn,'PS')) && ismember(levelProc,'S') % Project & subject level inputs, subject level processing
                argsOut=feval(fcnName,methodLetter,projData,subjData,projArgs,subjArgs);
            end
            
            continue; % No need to iterate through trials if no processing done there
        end
        
        currTrials=trialNames.(subName);
        for trialNum=1:length(currTrials)
            trialName=currTrials{trialNum};
            trialData=projectStruct.(subName).(trialName); % Nothing to exclude
            
            cd(argsFolder);
            [~,~,trialArgs]=feval(argsName,level,projectStruct,subName,trialName);
            
            cd(fcnFolder{i});
            argsOut=feval(fcnName,methodLetter,projectStruct,projArgs,subjArgs,trialArgs);
            
            
        end
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
    switch level
        case 'P' % Project
            % Run the processing arguments function
            cd(argsFolder);
            argsIn=feval(argsName,projectStruct); % No arguments below project level allowed
            
            % Evaluate the arguments.
            argsNames=fieldnames(argsInPaths);
            for argNum=1:length(argsNames)
                argName=argsNames{argNum};
                if ~iscell(argsInPaths.(argName)) % Character vector or double entered, e.g. numMethods will be one.
                    argsInPaths.(argName)={argsInPaths.(argName)};
                end
                numMethods=length(argsInPaths.(argName)); % Number of elements in cell array of paths
                
                for methodNum=1:length(numMethods)
                    
                    % Need to clean up handling of projectStruct addresses as inputs vs. inputting direct values (e.g. chars and doubles)
                    if existField(projectStruct,argsInPaths.(argName){methodNum})
                        try
                            argsIn.(argName){methodNum}=eval(argsInPaths.(argName){methodNum}); % projectStruct address that needs to be evaluated to obtain the data
                        catch
                            argsIn.(argName){methodNum}=argsInPaths.(argName){methodNum}; % data directly entered, e.g. a number or character vector
                        end
                    else % Display a warning that the argument was not found?
                        
                    end
                    
                end
                
            end
            
            % Run the processing function
            cd(fcnFolder{i});
            argsOut=feval(fcnName,argsIn);
            cd(currDir);
            
            % Save all of the arguments from the argsOut to file, and store them all to the projectStruct.
            saveAndStoreVars(argsOut,dataPath);
            
        case {'S','PS'} % Subject is the lowest level of processing.
            for subNum=1:length(subNames)
                subName=subNames(subNum);
                
                % Run the processing arguments function
                cd(argsFolder);
                argsInPaths=feval(argsName,projectStruct,subName); % No arguments below subject-level allowed
                
                % Evaluate the arguments.
                argsNames=fieldnames(argsInPaths);
                for argNum=1:length(argsNames)
                    argName=argsNames{argNum};
                    if ~iscell(argsInPaths.(argName)) % Character vector or double entered, e.g. numMethods will be one.
                        argsInPaths.(argName)={argsInPaths.(argName)};
                    end
                    numMethods=length(argsInPaths.(argName)); % Number of elements in cell array of paths
                    
                    for methodNum=1:length(numMethods)
                        
                        % Need to clean up handling of projectStruct addresses as inputs vs. inputting direct values (e.g. chars and doubles)
                        if existField(projectStruct,argsInPaths.(argName){methodNum})
                            try
                                argsIn.(argName){methodNum}=eval(argsInPaths.(argName){methodNum}); % projectStruct address that needs to be evaluated to obtain the data
                            catch
                                argsIn.(argName){methodNum}=argsInPaths.(argName){methodNum}; % data directly entered, e.g. a number or character vector
                            end
                        else % Display a warning that the argument was not found?
                            
                        end
                        
                    end
                    
                end
                
                % Run the processing function
                cd(fcnFolder{i});
                argsOut=feval(fcnName,argsIn,methodLetter,subName);
                cd(currDir);
                
                % Save all of the arguments from the argsOut to file, and store them all to the projectStruct.
                saveAndStoreVars(argsOut,dataPath);
                
            end
            
        case {'T','PT','PST','ST'} % Trial is the lowest level of processing
            for subNum=1:length(subNames)
                subName=subNames{subNum};
                subTrialNames=trialNames.(subName);
                for trialNum=1:length(subTrialNames)
                    trialName=subTrialNames{trialNum};
                    
                    % How to handle multiple repetitions within one trial?
                    
                    % Run the processing arguments function
                    cd(argsFolder);
                    argsInPaths=feval(argsName,projectStruct,subName,trialName); % Subject and trial level arguments allowed
                    
                    % Evaluate the arguments.
                    argsNames=fieldnames(argsInPaths);
                    for argNum=1:length(argsNames)
                        argName=argsNames{argNum};
                        if ~iscell(argsInPaths.(argName)) % Character vector or double entered, e.g. numMethods will be one.
                            argsInPaths.(argName)={argsInPaths.(argName)};
                        end
                        numMethods=length(argsInPaths.(argName)); % Number of elements in cell array of paths
                        
                        for methodNum=1:length(numMethods)
                            
                            % Need to clean up handling of projectStruct addresses as inputs vs. inputting direct values (e.g. chars and doubles)
                            if existField(projectStruct,argsInPaths.(argName){methodNum})
                                try
                                    argsIn.(argName){methodNum}=eval(argsInPaths.(argName){methodNum}); % projectStruct address that needs to be evaluated to obtain the data
                                catch
                                    argsIn.(argName){methodNum}=argsInPaths.(argName){methodNum}; % data directly entered, e.g. a number or character vector
                                end
                            else % Display a warning that the argument was not found?
                                
                            end
                            
                        end
                        
                    end
                    
                    % Run the processing function
                    disp(['RUNNING ' fcnName ' ' subName ' ' trialName]);
                    cd(fcnFolder{i});
                    argsOut=feval(fcnName,argsIn,methodLetter,subName,trialName);
                    cd(currDir);
                    
                    % Save all of the arguments from the argsOut to file, and also store them all to the projectStruct.
                    saveAndStoreVars(argsOut,dataPath);
                    
                end
            end
    end
    
end