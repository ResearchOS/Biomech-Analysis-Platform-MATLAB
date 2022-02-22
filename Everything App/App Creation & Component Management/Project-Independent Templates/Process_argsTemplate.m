function [argVal]=Process_argsTemplate(argName,projectStruct,subName,trialName)

%% PURPOSE: TEMPLATE FOR IMPORT ARGUMENTS FUNCTIONS
% Inputs:
% argName: The name of the input argument. Specifies which function to call (char)
% projectStruct: The entire project's data (struct)
% subName: The current subject's name (char)
% trialName: The current trial's name (char)

% Outputs:
% argVal: The input argument value (any data type), or the path to store the output argument (char)

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
function [argOut]=comVeloc(projectStruct,subName,trialName) 
% projectStruct path can be provided in this format only.
argOut='projectStruct.(subName).(trialName).Results.Mocap.Cardinal.COMVelocity';
end