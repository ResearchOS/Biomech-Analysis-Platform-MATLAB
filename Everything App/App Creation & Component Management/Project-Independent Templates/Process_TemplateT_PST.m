function Process_TemplateT_PST(trialStruct,methodLetter,varargin)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER TRIAL.
% Inputs:
% trialStruct: Data for one trial (struct)
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% varargin: Trial level inputs from the input argument function (cell array, each element is one variable)

%% Do Not Edit. Setup Before Running.
if nargin==0
    assignin('base','levelIn','T'); % Indicates trial level function inputs
    assignin('base','levelOut','PST'); % Indicates trial level function outputs
    return;
end

subNames=fieldnames(trialNames); % Get the list of subject names
for sub=1:length(subNames)
    subName=subNames{sub}; % Current subject name
    subjArgs=getSubjArgs(subName); % Get the subject-specific input arguments from the input arguments function.
    
    currTrials=trialNames.(subName); % Get the list of trial names in this subject.
    for trialNum=1:length(currTrials)
        trialName=currTrials{trialNum}; % Current trial name
        trialArgs=getTrialArgs(subName,trialName); % Get the trial-specific input arguments from the input arguments function
        
        %% TODO: Assign trial-level input arguments to variable names
        % Code here
        comPosition=trialArgs{1}; % Example
        
        %% TODO: Trial-level biomechanical operations
        trialCount=trialCount+1; % Example
        subTrialCount=subTrialCount+1; % Example
        meanCOMPos(trialCount)=mean(comPosition)*normHeight; % Example 
        meanCOMPosSub(subTrialCount)=mean(comPosition)*normHeight; % Example.
        
        %% TODO: Store the computed trial-level variable(s) data to the projectStruct
        trialData.Results.MeanCOMPosition=meanCOMPos(trialCount); % Example
        storeAndSaveVars(trialData,'T'); % Char here indicates output level
        
    end
    
    %% TODO (if applicable): Subject-level biomechanical operations
    % Code here
    subCOMPos=mean(meanCOMPosSub); % Example
    
    %% TODO: Store the computed subject-level variable(s) data to the projectStruct.
    subjData.Results.MeanCOMPosition.(['Method1' methodLetter])=subCOMPos; % Example
    
    storeAndSaveVars(subjData,'S'); % Char here indicates output level
    
end

%% TODO (if applicable): Project-level biomechanical operations
% Code here
changeCOMPos=meanCOMPos*2; % Example

%% TODO: Store the computed variable(s) data to the projectStruct
projStruct.Results.MeanCOMPosition.(['Method1' methodLetter])=changeCOMPos; % Example
projStruct.Info.CollectionSite.(['Method1' methodLetter])=collectionSite; % Example

% Store the projectStruct to the base workspace and saves project-level data to file.
storeAndSaveVars(projStruct,'P'); % Char here indicates output level