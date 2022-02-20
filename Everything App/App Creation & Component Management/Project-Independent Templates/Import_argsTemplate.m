function [argVal]=Import_argsTemplate(argName,projectStruct,subName,trialName)

%% PURPOSE: TEMPLATE FOR IMPORT ARGUMENTS FUNCTIONS
% QUESTION: DO I NEED A VARIABLE THAT EXPLICITLY SPECIFIES IF CALLING AN INPUT OR OUTPUT ARGUMENT?
% WOULD ONLY BE NECESSARY IF INPUT & OUTPUT ARGS FUNCTIONS HAVE IDENTICAL NAMES

% Inputs:
% argName: The name of the input argument. Specifies which function to call (char)
% projectStruct: The entire project's data (struct)
% subName: The current subject's name (char)
% trialName: The current trial's name (char)

% Outputs:
% argVal: The input argument value (any data type), or the path to store the output argument (char)

localFcns=localfunctions; % Get the handles of all function names in the args file, to explicitly ensure that only these functions are called.
fcnExist=0; % Initialize that the local function does not exist in this file
for i=1:length(localFcns)
    currFcn=func2str(fh); % Get the name of each local function in this file
    if isequal(currFcn,argName)
        fcnExist=1; % Indicates that the function is found in this file.
        break;
    end
end
if fcnExist==0
    error(['Argument Function not Found in Function ' mfilename ': ' argName]);
end

% Run the appropriate input arguments function. Local functions take precedence over all others besides nested functions.
argVal=feval(argName,projectStruct,subName,trialName);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT EDIT FROM HERE UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Input argument
function [argIn]=comPos(projectStruct,subName,trialName)
    
    argIn=projectStruct.(subName).(trialName).Results.Mocap.Cardinal.COMPosition.Method1A;

end

%% Output argument. Do not include Method ID field, as that will be automatically assigned.
function [argOut]=comVeloc(~,subName,trialName)
    
    % projectStruct path can be provided in this format only.   
    argOut='projectStruct.(subName).(trialName).Results.Mocap.Cardinal.COMVelocity';

end