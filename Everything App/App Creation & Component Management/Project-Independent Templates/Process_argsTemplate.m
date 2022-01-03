function [argsVars,argsPaths]=Process_argsTemplate(projectStruct,subName,trialName,repNum)

%% PURPOSE: SPECIFY THE INPUT ARGUMENTS FOR A PROCESSING FUNCTION
% Inputs:
% projectStruct: The whole structure containing all data (struct)
% subName: The current subject's name (char)
% trialName: The current trial's name within the subject (char)
% repNum: The current repetition number within the trial (double)

% Outputs: Two types of input arguments to the processing functions:
% 1: Argument variables: These are the actual data that will go into the function itself
% 2: Argument paths: These are the paths within the projectStruct for each argument, so that they can be loaded & offloaded individually.
% If the paths and the variables can not match exactly, for whatever reason, then the paths should be more inclusive (i.e. load extra stuff).
% If the variables are more inclusive, then the processing may not work when loading data individually.

%% Specify argsPaths here
if nargin==0
   argsPaths{1}='projectStruct.(subName).(trialName).Results.Mocap.Cardinal.COMPosition.Method1A'; % Example
   argsPaths{2}='projectStruct.(subName).(trialName).Info.Mocap.StartFrame.Method1A'; % Example
   argsPaths{3}='projectStruct.(subName).(trialName).Info.Mocap.EndFrame.Method1A'; % Example
    return;
end

%% Specify argsVars here
argsVars.COMPosition.Method1A=projectStruct.(subName).(trialName).Results.Mocap.Cardinal.COMPosition.Method1A; % Example
argsVars.StartFrame.Method1A=projectStruct.(subName).(trialName).Info.Mocap.StartFrame.Method1A; % Example
argsVars.EndFrame.Method1A=projectStruct.(subName).(trialName).Info.Mocap.EndFrame.Method1A; % Example