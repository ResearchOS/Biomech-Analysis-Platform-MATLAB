function [dataOut]=Process_TemplateS(methodLetter,subName,varargin)

%% PURPOSE: TEMPLATE FOR SUBJECT & PROJECT-LEVEL PROCESSING FUNCTIONS. THIS FUNCTION IS CALLED ONCE PER SUBJECT.
% Inputs:
% methodLetter: The method letter for all output arguments. Matches the letter of the current input arguments function. (char)
% subName: The subject name (char)

%% Setup to establish processing level
if nargin==0
    argsOut='S'; % Indicates trial level function
    return;
end

%% TODO: Store the structure path to the output variable.
% dataOut{m,n}, where
% m=argument number, and
% n=1 indicates the path name, and 
% n=2 indicates the actual data
dataOut{1,1}=['projectStruct.' subName '.Normalization.Method1' methodLetter];

if nargin==2 % Indicates to only return the variable path names
    return;
end

%% TODO: Assign input arguments to variable names
normFactor1=varargin{1};
normFactor2=varargin{2};

%% TODO: Biomechanical operations for each subject.
% Code here
normFactor=normFactor1*normFactor2;

%% TODO: Store the computed variable(s) data to the output variable.
% dataOut{m,n}, where
% m=argument number, and
% n=1 indicates the path name, and 
% n=2 indicates the actual data
dataOut{1,2}=normFactor;