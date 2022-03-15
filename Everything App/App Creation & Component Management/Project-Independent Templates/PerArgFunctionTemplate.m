function [argPath,argVal]=PerArgFunctionTemplate(projectStruct,subName,trialName,repNum)

%% PURPOSE: TEMPLATE FOR ARGUMENT FUNCTIONS
% Outputs:
% argPath: (required) The position in the struct where the argument is to be stored (char) i.e. 'projectStruct.(subName).(trialName).Info(repNum).Mocap...'
% If not wanting to store the value provided here, set argPath to 'projectStruct.Placeholder';
% argVal: (optional) The value of the argument (any data type)

argPath='projectStruct.(subName).(trialName).Results(repNum)';

argVal=projectStruct.(subName).(trialName).Results(repNum);