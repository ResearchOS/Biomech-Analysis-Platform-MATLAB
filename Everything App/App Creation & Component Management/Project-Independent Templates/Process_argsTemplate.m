function [argIn]=Process_argsTemplate(projectStruct,argName,subName,trialName)

%% PURPOSE: SPECIFY THE INPUT ARGUMENTS FOR A PROCESSING FUNCTION. THIS FUNCTION'S TEXT IS READ BY PROCESSRUNFUNCTIONS.M, THIS FUNCTION IS NEVER ACTUALLY RUN.
% Inputs: None

% Outputs: None
% The method ID is not specified in the outputs because that will be automatically assigned based on the current processing function's number & this
% argument's letter

%% Input arguments
startFrame=projectStruct.(subName).(trialName).Mocap.Info.StartFrame.Method1A; % Example
endFrame=projectStruct.(subName).(trialName).Mocap.Info.EndFrame.Method1A; % Example
comPos=projectStruct.(subName).(trialName).Mocap.Results.COMPosition.Method1A; % Example

%% Output arguments
projectStruct.(subName).(trialName).Mocap.Results.COMVelocity=comVeloc; % Example