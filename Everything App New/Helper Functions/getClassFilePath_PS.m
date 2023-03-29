function [fullPath]=getClassFilePath_PS(name_PS, class)

%% PURPOSE: RETURN THE FULL FILE PATH FOR THE SPECIFIED PROJECT-SPECIFIC STRUCT.

slash=filesep;

% projectPath=getProjectPath(1);

classFolder=[getCommonPath slash class slash 'Implementations'];
% classFolder=[projectPath slash 'Project_Settings' slash class];

fullPath=[classFolder slash class '_' name_PS '.json'];