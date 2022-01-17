function [argsIn,dataIn]=getArgs(methodLetter,subName,trialName,fcnName)

%% PURPOSE: RETURN ARGUMENTS FROM THE PROJECTSTRUCT FOR THE APPROPRIATE SUBJECT OR TRIAL
% Inputs:
% methodLetter: Which argument method letter to use (char)
% subName: The current subject name (char)
% trialName: The current trial name (char)
% fcnName: The function about to be run. Only used when this function is called by runProcessFunctions. Otherwise obtained by looking at the stack (char)

% Outputs:
% argsOut: The input arguments for the processing function (cell array, each arg is one element)

if nargin==0
    error('Missing method letter for input arguments');
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% Get the projectStruct from the base workspace.
projectStruct=evalin('base','projectStruct;');

% Get the fig from the base workspace.
fig=evalin('base','gui;');

codePath=getappdata(fig,'codePath');
projectName=getappdata(fig,'projectName');
argsPath=[codePath 'Process_' projectName slash 'Arguments'];

% Get the current function input arguments function name
if nargin==4 % Called from runProcessFunctions
    if ischar(trialName)
        numVars=3;
    elseif ischar(subName)
        numVars=2;
    else
        numVars=1;
    end    
else % Called from any Process function
    st=dbstack;
    fcnName=st(2).name;
    numVars=nargin;
end

argsName=[fcnName methodLetter]; % The argument function name

currDir=cd(argsPath); % Change to the directory of the arguments function

% Get subject codename column number
subjColNum=getappdata(fig,'subjectCodenameColumnNum');

% Get trial name column number
trialColNum=getappdata(fig,'trialNameColumnNum');

switch numVars
    case 1 % Get project-level input arguments
        subjectNames=getappdata(fig,'subjectNames');
        
        fldNames=fieldnames(projectStruct); % field names of the projectStruct
        fldNames=fldNames(~ismember(fldNames,subjectNames)); % Exclude the subject names from the list of field names to use.
        if isempty(fldNames)
            beep;
            warning('No project level data');
            argsIn=0; dataIn=0;
            return;
        end
        for i=1:length(fldNames)
            dataIn.(fldNames{i})=projectStruct.(fldNames{i}); % Excludes subject data
        end
        [argsIn]=feval(argsName,'P',dataIn);
        
    case 2 % Get subject-level input arguments      
        logVar=evalin('base','logVar;');
        if ~isvarname(subName)
            logSubName=['S' subName]; % If not previously corrected, correct it.
        end
        if ~isvarname(subName(2:end)) && isequal(subName(1),'S') && isvarname(subName)
            logSubName=subName(2:end); % Correct a previous correction
        end
        
        subCellsIdx=ismember(logVar(:,subjColNum),logSubName); % The row numbers of all the columns in this subject.
        trialNames=logVar(subCellsIdx,trialColNum); % All of the trial names in this subject
        for i=1:length(trialNames)
            if ~isvarname(trialNames{i})
                trialNames{i}=['T' trialNames{i}];
            end
            if ~isvarname(trialNames{i})
                error(['Wrong trial name in Subject: ' subName ' Trial: ' trialNames{i}]);
            end
        end
        
        if ~isfield(projectStruct,subName)
            beep;
            warning(['Subject does not exist in projectStruct: ' subName]);
            argsIn=0; dataIn=0;
            return;
        end
        fldNames=fieldnames(projectStruct.(subName));
        fldNames=fldNames(~ismember(fldNames,trialNames)); % Exclude the trial names for this subject from the list of field names to use.
        if isempty(fldNames)
            beep;
            warning(['No subject level data in subject: ' subName]);
            argsIn=0; dataIn=0;
            return;
        end
        for i=1:length(fldNames)
            dataIn.(fldNames{i})=projectStruct.(subName).(fldNames{i});
        end
        
        [argsIn]=feval(argsName,'S',dataIn);
        
    case 3 % Get trial-level input arguments
        if isfield(projectStruct.(subName),trialName)
            dataIn=projectStruct.(subName).(trialName); % Don't need to remove anything.
        else
            beep;
            warning(['Trial does not exist in projectStruct: subject ' subName ' trial ' trialName]);
            argsIn=0; dataIn=0;
            return;
        end
        [argsIn]=feval(argsName,'T',dataIn);
        if isempty(fieldnames(projectStruct.(subName).(trialName)))
            beep;
            warning(['No trial level data in subject: ' subName ' trial: ' trialName]);
            argsIn=0; dataIn=0;
            return;
        end
        
end

cd(currDir); % Change back to the original directory