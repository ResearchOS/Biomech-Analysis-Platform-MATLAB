function Process_TemplatePT_PT(projStruct,methodLetter,trialNames,projData,projArgs)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER PROJECT.
% Inputs:
% projectStruct: The entire data struct. Used for saving ONLY.
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% varargin: The input variables from the input arguments function (cell array, each element is one variable)

%% Setup to establish processing level
if nargin==0
    assignin('base','levelIn','PT'); % Indicates project level function inputs
    assignin('base','levelOut','PT'); % Indicates project level function outputs
    return;
end

%% TODO: Assign input arguments to variable names
roomNum=projArgs{1};
constant=projArgs{2};

%% TODO: Biomechanical operations for the whole project.
% Code here.
collectionSite=['Zaferiou Lab' roomNum];

trialCount=0; % Example. Initialize number of trials.
subTrialCount=0; % Example. Initialize number of trials per subject.

subNames=fieldnames(trialNames); % Get the list of subject names
for sub=1:length(subNames)
    subName=subNames{sub}; % Current subject name
    
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
    
end

%% TODO (if applicable): Project-level biomechanical operations
% Code here
changeCOMPos=meanCOMPos*2; % Example

%% TODO: Store the computed variable(s) data to the projectStruct
projStruct.Results.MeanCOMPosition.(['Method1' methodLetter])=changeCOMPos; % Example
projStruct.Info.CollectionSite.(['Method1' methodLetter])=collectionSite; % Example

% Store the projectStruct to the base workspace and saves project-level data to file.
storeAndSaveVars(projStruct,'P'); % Char here indicates output level