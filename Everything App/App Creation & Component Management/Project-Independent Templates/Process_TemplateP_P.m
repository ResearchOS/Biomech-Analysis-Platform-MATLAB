function Process_TemplateP_P(projStruct,methodLetter,projData,projArgs)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER PROJECT.
% Inputs:
% projectStruct: The entire data struct. Used for saving ONLY.
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% varargin: The input variables from the input arguments function (cell array, each element is one variable)

%% Setup to establish processing level
if nargin==0
    assignin('base','levelIn','P'); % Indicates project level function inputs
    assignin('base','levelOut','P'); % Indicates project level function outputs
    return;
end

%% TODO: Assign input arguments to variable names
roomNum=projArgs{1};

%% TODO: Biomechanical operations for the whole project.
% Code here.
collectionSite=['Zaferiou Lab' roomNum];

%% TODO: Store the computed variable(s) data to the projectStruct
projStruct.Info.CollectionSite.(['Method1' methodLetter])=collectionSite;

% Store the projectStruct to the base workspace and saves project-level data to file.
storeAndSaveVars(projStruct,'P'); % Char here indicates output level