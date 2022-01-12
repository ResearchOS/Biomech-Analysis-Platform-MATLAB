function [projArgs,subjArgs,trialArgs]=Process_argsTemplate(level,projectStruct,subName,trialName,repNum)

%% PURPOSE: SPECIFY THE INPUT ARGUMENTS FOR A PROCESSING FUNCTION
% Inputs:
% level: The level to return arguments from (char)
% projectStruct: The whole structure containing all data (struct)
% subName: The current subject's name (char)
% trialName: The current trial's name within the subject (char)
% repNum: The current repetition number within the trial (double)

% Outputs:
% projArgs: The project-level input arguments to the processing function (cell array)
% subjArgs: The subject-level input arguments to the processing function (cell array)
% trialArgs: The trial-level input arguments to the processing function (cell array)

%% Specify arguments here
% Trial-level arguments here
if ismember(level,'T') 
    
    trialArgs{1}=projectStruct.(subName).(trialName).Results.Mocap.Cardinal.COMPosition.Method1A; % Example
    trialArgs{2}=projectStruct.(subName).(trialName).Info.Mocap.StartFrame.Method1A; % Example
    trialArgs{3}=projectStruct.(subName).(trialName).Info.Mocap.EndFrame.Method1A; % Example
    
end

% Subject-level arguments here
if ismember(level,'S') 
    
    
    
end

% Per-project arguments here
if ismember(level,'P') 
   
    
    
end

%% Create vars that don't exist just to have something to output
if ~exist('trialArgs','var')
    trialArgs=0;
end
if ~exist('subjArgs','var')
    subjArgs=0;
end
if ~exist('projArgs','var')
    projArgs=0;
end