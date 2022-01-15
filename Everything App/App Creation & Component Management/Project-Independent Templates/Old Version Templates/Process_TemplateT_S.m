function Process_TemplateT_S(trialStruct,methodLetter,trialNames,subjData,subjArgs)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER TRIAL.
% Inputs:
% trialStruct: Data for one trial (struct)
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% varargin: Trial level inputs from the input argument function (cell array, each element is one variable)

%% Do Not Edit. Setup Before Running.
if nargin==0
    assignin('base','levelIn','T'); % Indicates trial level function inputs
    assignin('base','levelOut','S'); % Indicates trial level function outputs
    return;
end

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
    
end

%% TODO (if applicable): Subject-level biomechanical operations
% Code here
subCOMPos=mean(meanCOMPosSub); % Example

%% TODO: Store the computed subject-level variable(s) data to the projectStruct.
subjData.Results.MeanCOMPosition.(['Method1' methodLetter])=subCOMPos; % Example

storeAndSaveVars(subjData,'S'); % Char here indicates output level