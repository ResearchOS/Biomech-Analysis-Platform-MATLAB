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

setappdata(fig,'guiTab','Process');
setappdata(fig,'groupName',groupName);

savePathsByLevel.Trial.Paths={};
savePathsByLevel.Subject.Paths={};
savePathsByLevel.Project.Paths={};
setappdata(fig,'savePathsByLevel',savePathsByLevel); % Initialize the savePathsByLevel to be empty.

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
groupArgsName=[groupName '_Process_Args'];

fcnCount=0;
for i=lineNum+1:length(text)

    if isempty(text{i})
        break; % Finished with this group
    end

    a=strsplit(text{i},':');
    runAndSpecifyTrialsCell=strsplit(strtrim(a{2}),' ');
    if isequal(runAndSpecifyTrialsCell{1}(end),'0')
        continue;
    end

    fcnCount=fcnCount+1;
    fcnNameCell=strsplit(a{1},' ');
    number=fcnNameCell{2}(~isletter(fcnNameCell{2}));
    letters{fcnCount}=fcnNameCell{2}(isletter(fcnNameCell{2}));
    fcnNames{fcnCount}=[fcnNameCell{1} '_Process' number]; % All the function names, in order
%     if isequal(runAndSpecifyTrialsCell{3}(end),'1') % if using function-specific argument function
%         argsNames{fcnCount}=[fcnNameCell{1} '_Process' number letter]; % All the argument function names, in order
%     else % if using group level argument function
%         argsNames{fcnCount}=groupArgsName;
%     end

    runFuncs(fcnCount)=str2double(runAndSpecifyTrialsCell{1}(end));
    funcSpecifyTrials(fcnCount)=str2double(runAndSpecifyTrialsCell{2}(end));
    funcArgs(fcnCount)=str2double(runAndSpecifyTrialsCell{3}(end));

    if isequal(runAndSpecifyTrialsCell{2}(end),'1')
        funcSpecifyTrialsName{fcnCount}=[fcnNameCell{1} '_Process' number letters{fcnCount} '_SpecifyTrials'];
    else
        funcSpecifyTrialsName{fcnCount}=groupSpecifyTrialsName;
    end

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

%% Check existence of all input arguments functions, and identify their highest processing level.
argsFolderFcn=[codePath 'Process_' projectName slash 'Arguments' slash 'Per Function' slash];
argsFolderGroup=[codePath 'Process_' projectName slash 'Arguments' slash 'Per Group' slash];
currDir=cd([codePath 'Process_' projectName slash 'Arguments']);
argPath=cell(length(fcnNames),1);

if ~exist('fcnNames','var')
    return;
end

specifyTrialsPath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'allProjects_SpecifyTrials.txt'];
text=regexp(fileread(specifyTrialsPath),'\n','split');
projFound=0;
currSpecTrialsName=cell(length(fcnNames),1);
funcLevels=cell(length(fcnNames),1);
inputPaths=cell(length(fcnNames),1);
outputPaths=cell(length(fcnNames),1);
allPaths=cell(length(fcnNames),1);

projectStruct=evalin('base','projectStruct;');

for i=1:length(fcnNames)

%     if exist([argsNames{i} '.m'],'file')~=2
%         beep;
%         warning(['Input Argument Function Does Not Exist: ' argsNames{i}]);
%         return;
%     end

%     if exist([argsFolderFcn argsNames{i} '.m'],'file')==2
%         argPath{i}=[argsFolderFcn argsNames{i} '.m'];
%     elseif exist([argsFolderGroup argsNames{i} '.m'],'file')==2
%         argPath{i}=[argsFolderGroup argsNames{i} '.m'];
%     end

    specTrials=funcSpecifyTrials(i); % 1 means function level, 0 means group level
    fcnName=fcnNames{i};

    % Need to run the specifyTrials for this function so that I can test it at each level.
    % Run the specify trials function, either function or group level.
    if isequal(specTrials,0) % Group level
        prefix=['Process Group ' groupName];
    elseif isequal(specTrials,1) % Function level
        splitName=strsplit(fcnName,'_Process');
        prefix=['Process Fcn ' splitName{1} splitName{2}];
    end
    for j=1:length(text)

        if projFound==0 && isequal(text{j}(1:length('Project Name:')),'Project Name:')
            projFound=1;
        end

        if projFound==0 || isempty(text{j})
            continue;
        end

        colonIdx=strfind(text{j},':');
        colonIdx=colonIdx(1);

        if length(text{j})>length(prefix) && ~isempty(strfind(text{j}(1:colonIdx-1),prefix)) % This is the correct specify trials version
            currSpecTrialsMPath=text{j}(colonIdx+2:end);
            [~,currSpecTrialsName{i}]=fileparts(currSpecTrialsMPath);
            break;
        end

    end

    % Read through all args functions and get what level they're at.
    levels='';
    argsText=readAllArgsTextFile(getappdata(fig,'everythingPath'),projectName,getappdata(fig,'guiTab'));
    argNames=getAllArgNames(argsText,projectName,getappdata(fig,'guiTab'),groupName,[fcnName letters{i}]);
    for j=1:length(argNames) % Iterate over all args of the current function
        argsPath=[codePath 'Process_' projectName slash 'Arguments' slash 'ProcessArg_' argNames{j} '.m'];
        [~,~,~,currLevels]=readArgsFcn(argsPath); % Returns 0 if the args function does not exist.
        if isequal(currLevels,0)
            warning(['Args function does not exist: ' argsPath]);
            return;
        end
        levels=[levels currLevels];
    end
    levels=sort(unique(levels));

    % Run specifyTrials & get the first subject name, trial name, & rep num for testing
    inclStruct=feval(currSpecTrialsName{i}); % Get the metadata for specifying trials
    trialNames=getTrialNames(inclStruct,logVar,fig,0,projectStruct); % Get the trial names
    subNames=fieldnames(trialNames);

    % Try running the args function at project, then subject, then trial levels. If it throws an error, check if the error is that the variable was
    % not returned. If so, go to the next level down. If no error, it is this level. If other error, throw that error.
    funcLevels{i}=levels;

end
cd(currDir); % Go back to original directory.

%% Iterate over all processing functions in the group to run them.
for i=1:length(fcnNames)

    % Bring the projectStruct from the base workspace into this one. Doing this for each function incorporates results of any previously finished functions.
    projectStruct=evalin('base','projectStruct;');

    fcnName=fcnNames{i};
%     argsName=argsNames{i};
    runFunc=runFuncs(i);
    currLevels=funcLevels{i};
    methodLetter=letters{i};
%     methodLetter=strsplit(argsName,'_Process');
%     methodLetter=methodLetter{2}(isletter(methodLetter{2}));
    setappdata(fig,'methodLetter',methodLetter);

    if runFunc==0
        disp(['Skipping ' fcnName ' Because it was Unchecked in Group ' groupName ' in the GUI']);
        continue; % If this function shouldn't be run this time, skip it.
    end

    inclStruct=feval(currSpecTrialsName{i}); % Run the appropriate specify trials for the current function.

    % Run getTrialNames
    trialNames=getTrialNames(inclStruct,logVar,fig,0,projectStruct);
    subNames=fieldnames(trialNames);

    % Run the processing function
    if ismember('Project',currLevels)

        disp(['Running ' fcnName]);

        if ismember('Trial',currLevels)
            feval(fcnName,projectStruct,trialNames); % projectStruct is an input argument for convenience of viewing the data only
        elseif ismember('Subject',currLevels)
            feval(fcnName,projectStruct,subNames);
        else
            feval(fcnName,projectStruct);
        end
        continue; % Don't iterate through subjects, that's done within the processing function if necessary
    end

    for sub=1:length(subNames)
        subName=subNames{sub};
        currTrials=fieldnames(trialNames.(subName)); % The list of trial names in the current subject

        if ismember('Subject',currLevels)

            disp(['Running ' fcnName ' Subject ' subName]);

            if ismember('Trial',currLevels)
                feval(fcnName,projectStruct,subName,trialNames.(subName)); % projectStruct is an input argument for convenience of viewing the data only
            else
                feval(fcnName,projectStruct,subName);
            end
            continue; % Don't iterate through trials, that's done within the processing function if necessary
        end

        for trialNum=1:length(currTrials)
            trialName=currTrials{trialNum};

            disp(['Running ' fcnName ' Subject ' subName ' Trial ' trialName]);

            for repNum=trialNames.(subName).(trialName)

                feval(fcnName,projectStruct,subName,trialName,repNum); % projectStruct is an input argument for convenience of viewing the data only

            end
        end

    end

end

%% Rearrange subject & trial names to be in alphabetical order.
for sub=1:length(subNames)

    subName=subNames{sub};
    %     trialNames=fieldnames(allTrialNames.(subName));

    evalin('base',['projectStruct.' subName '=orderfields(projectStruct.' subName ');' ]); % Rearrange trial names in alphabetical order.

end

evalin('base','projectStruct=orderfields(projectStruct);'); % Rearrange subject names in alphabetical order.

%% Save the entire processing function group's output
% Save the data to the appropriate file. Use parallel pool if desired.
p=gcp('nocreate');
if isempty(p)
    p=parpool('local',1);
end
disp('Finished processing! Handing data off to parallel pool for saving!');
savePathsByLevelFig=getappdata(fig,'savePathsByLevel');
% f=parfeval(p,@saveDataToFile,0,fig,evalin('base','projectStruct;'),savePathsByLevelFig);
saveDataToFile(fig,evalin('base','projectStruct;'),savePathsByLevelFig);