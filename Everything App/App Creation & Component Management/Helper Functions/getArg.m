function [argIn]=getArg(argName,subName,trialName)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% argName: The name of the input argument. Spelling must match the input arguments function (char)
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)

% Outputs:
% argIn: The argument to pass in to the processing function

fig=evalin('base','gui;');

if nargin<=2 % Subject level data
    trialName='';
end
if nargin==1 % Project level data
    subName='';
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% 1. Get the name of the corresponding input argument file
% fig=evalin('base','gui;'); % Get the gui from the base workspace.
st=dbstack;
fcnName=st(2).name; % The name of the calling function.
methodLetter=getappdata(fig,'methodLetter'); % Get the method letter from the base workspace

useGroupArgs=0; % 1 to use group args, 0 not to. This will be replaced by GUI checkbox value later.
if useGroupArgs==1 % Group level arguments
    
else
%     argsFunc=[argsFolder slash fcnName methodLetter '_' argName]; % The full path to the arguments file
    argsFuncName=[fcnName methodLetter];
end

if evalin('base','exist(''projectStruct'',''var'')~=1')
    evalin('base','projectStruct=''''');
end

argIn=feval(argsFuncName,argName,evalin('base','projectStruct;'),subName,trialName);