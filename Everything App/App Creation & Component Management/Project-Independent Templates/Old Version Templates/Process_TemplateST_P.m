function Process_TemplateST_P(subjStruct,methodLetter,trialNames)

%% PURPOSE: TEMPLATE FOR SUBJECT & PROJECT-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION IS CALLED ONCE PER SUBJECT.
% Inputs:
% subjStruct: The subject level data (struct)
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% subName: The subject name (char)

%% Setup to establish processing level
if nargin==0
    assignin('base','levelIn','ST'); % Indicates subject level function inputs
    assignin('base','levelOut','P'); % Indicates subject level function outputs
    return;
end

subNames=fieldnames(trialNames); % Get the list of subject names
for sub=1:length(subNames)
    subName=subNames{sub}; % Current subject name
    subjArgs=getSubjArgs(subName); % Get the subject-specific input arguments from the input arguments function.
    
    %% TODO: Assign subject-level input arguments to variable names
    % Code here
    height=subjArgs{1}; % Example
    
    %% TODO (if applicable): Subject-level biomechanical oeperations
    % Code here
    normHeight=height*constant; % Example
    
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
    
end

%% TODO (if applicable): Project-level biomechanical operations
% Code here
changeCOMPos=meanCOMPos*2; % Example

%% TODO: Store the computed variable(s) data to the projectStruct
projStruct.Results.MeanCOMPosition.(['Method1' methodLetter])=changeCOMPos; % Example
projStruct.Info.CollectionSite.(['Method1' methodLetter])=collectionSite; % Example

% Store the projectStruct to the base workspace and saves project-level data to file.
storeAndSaveVars(projStruct,'P'); % Char here indicates output level