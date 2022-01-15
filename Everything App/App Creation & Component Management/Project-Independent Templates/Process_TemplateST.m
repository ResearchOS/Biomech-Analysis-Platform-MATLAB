function Process_TemplateST(projectStruct,subName,trialNames)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER PROJECT.
% Inputs:
% projectStruct: The entire data struct. Used for saving ONLY.
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% varargin: The input variables from the input arguments function (cell array, each element is one variable)

%% Setup to establish processing level & output arguments
if nargin==0
    assignin('base','levels','ST'); % Indicates project level function inputs
    return;
end

%% TODO: Assign input arguments to variable names
roomNum=getArg('roomNum',subName);

for trialNum=1:length(trialNames)
    trialName=trialNames{trialNum};
    
    comPos=getArg('trialArg',subName,trialName);
    
    setArg('comPos',comPos,subName,trialName);
    
end

%% TODO: Biomechanical operations for the whole project.
% Code here.
collectionSite=['Zaferiou Lab' roomNum];

%% TODO: Store the computed variable(s) data to the projectStruct
setArg('roomNum',subName);