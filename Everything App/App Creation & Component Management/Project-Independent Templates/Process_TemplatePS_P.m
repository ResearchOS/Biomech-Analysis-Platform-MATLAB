function Process_TemplatePS_P(projectStruct,methodLetter,subNames,projData,projArgs)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER PROJECT.
% Inputs:
% projectStruct: The entire data struct. Used for saving ONLY.
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% subNames: The subject names (cell array of chars)
% varargin: The project-level input variables from the input arguments function (cell array, each element is one variable)

%% Setup to establish processing level
if nargin==0
    assignin('base','levelIn','PS'); % Indicates project level function inputs
    assignin('base','levelOut','P'); % Indicates project level function outputs
    return;
end

%% TODO: Assign project-level input arguments to variable names
roomNum=projArgs{1};

%% TODO (if applicable): Project-level biomechanical operations
% Code here.
sumHeights=0;

for sub=1:length(subNames)
    subName=subNames{sub}; % Current subject name        
    subjArgs=getSubjArgs(subName); % Get the subject-specific input arguments from the input arguments function.
    
    %% TODO: Assign subject-level input arguments to variable names
    % Code here
    height=subjArgs{1};
    
    %% TODO: Subject-level biomechanical operations
    % Code here
    sumHeights=height+sumHeights;
    
end

%% TODO (if applicable): Project-level biomechanical operations
% Code here.
collectionSite=['Zaferiou Lab' roomNum];

%% TODO: Store the computed variable(s) data to the projectStruct
projData.Info.CollectionSite.(['Method1' methodLetter])=collectionSite;
projData.Info.MeanHeight=mean(sumHeights);

% Store the projectStruct to the base workspace and saves project-level data to file.
storeAndSaveVars(projData,'P'); % Char here indicates output level