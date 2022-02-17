function setArg(subName,trialName,varargin)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)
% varargin: The value of each output argument. The name passed in to this function must exactly match what is in the input arguments function (any data type)

% persistent p;

st=dbstack;
fcnName=st(2).name; % The name of the calling function.

argNames=cell(length(varargin),1);
nArgs=length(varargin);
for i=3:nArgs+2
    argNames{i-2}=inputname(i); % NOTE THE LIMITATION THAT THERE CAN BE NO INDEXING USED IN THE INPUT VARIABLE NAMES
    if isempty(argNames{i-2})
        error(['Argument #' num2str(i) ' (output variable #' num2str(i-2) ') is not a scalar name in ' fcnName ' line #' num2str(st(2).line)]);
    end
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

st=dbstack;
fcnName=st(2).name;
methodLetter=evalin('base','methodLetter;');

useGroupArgs=0; % 1 to use group args, 0 not to. This will be replaced by GUI checkbox value later.
if useGroupArgs==1
    
else
    argsFuncName=[fcnName methodLetter];
end

for i=1:length(argNames)
    argName=argNames{i};
    argIn=feval(argsFuncName,argName,projectStruct,subName,trialName);
    
    % Resolve the path names (i.e. subName & trialName)
    
    
    % Store the data to the appropriate path
    
    
end

% Save the data to the appropriate file. If R2021b or later, use the
% backgroundPool to save the data to files.
if exist('backgroundPool','builtin')
    p=backgroundPool;
    f=parfeval(p,@saveData,0,projectStruct,subName,trialName);
else
    saveData(projectStruct,subName,trialName);
end