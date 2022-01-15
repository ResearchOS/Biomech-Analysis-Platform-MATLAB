function Process_TemplateT_T(trialStruct,methodLetter,trialData,trialArgs)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER TRIAL.
% Inputs:
% trialStruct: Data for one trial (struct)
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% varargin: Trial level inputs from the input argument function (cell array, each element is one variable)

%% Do Not Edit. Setup Before Running.
if nargin==0
    assignin('base','levelIn','T'); % Indicates trial level function inputs
    assignin('base','levelOut','T'); % Indicates trial level function outputs
    return;
end

%% TODO: Assign trial-level input arguments to variable names
% Code here
comPosition=trialArgs{1}; % Example

%% TODO: Trial-level biomechanical operations
meanCOMPos=mean(comPosition); % Example

%% TODO: Store the computed trial-level variable(s) data to the projectStruct
trialData.Results.MeanCOMPosition=meanCOMPos(trialCount); % Example
storeAndSaveVars(trialData,'T'); % Char here indicates output level