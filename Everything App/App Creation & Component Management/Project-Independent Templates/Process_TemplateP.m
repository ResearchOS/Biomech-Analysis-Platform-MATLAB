function [dataOut]=Process_TemplateP(methodLetter,varargin)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION WILL BE CALLED ONCE PER PROJECT.
% Inputs:
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)

%% Setup to establish processing level
if nargin==0
    dataOut='P'; % Indicates trial level function
    return;
end

%% TODO: Store the structure path to the output variable.
% dataOut{m,n}, where
% m=argument number, and
% n=1 indicates the path name, and 
% n=2 indicates the actual data
dataOut{1,1}=['projectStruct.CollectionSite.Method1' methodLetter];

if nargin==1
    return;
end

%% TODO: Assign input arguments to variable names
roomNum=varargin{1};

%% TODO: Biomechanical operations for the whole project.
% Code here.
collectionSite=['Zaferiou Lab' roomNum];

%% TODO: Store the computed variable(s) data to the output variable.
% dataOut{m,n}, where
% m=argument number, and
% n=1 indicates the path name, and 
% n=2 indicates the actual data
dataOut{1,2}=collectionSite;