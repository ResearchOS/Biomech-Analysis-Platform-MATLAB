function Process_TemplateT(projectStruct,subName,trialName,repNum)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER TRIAL.
% Inputs:
% projectStruct: The entire data struct. Used for saving ONLY.
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% varargin: The input variables from the input arguments function (cell array, each element is one variable)

%% TODO: Assign input arguments to variable names
roomNum=getArg('roomNum',subName,trialName,repNum); % Get trial level variable

%% TODO: Biomechanical operations for the whole project.
% Code here.
collectionSite=['Zaferiou Lab' roomNum];

%% TODO: Store the computed variable(s) data to the projectStruct
setArg(subName,trialName,repNum,collectionSite); % Set trial level variable