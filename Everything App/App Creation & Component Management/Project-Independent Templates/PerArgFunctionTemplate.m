function [argVal,argPath]=PerArgFunctionTemplate(projectStruct,subName,trialName,repNum)

%% PURPOSE: TEMPLATE FOR ARGUMENT FUNCTIONS
% Outputs:
% argVal: The value of the argument (any data type)
% argPath: The position in the struct where the argument is to be stored (char) i.e. 'projectStruct.(subName).(trialName).Info(repNum).Mocap...'