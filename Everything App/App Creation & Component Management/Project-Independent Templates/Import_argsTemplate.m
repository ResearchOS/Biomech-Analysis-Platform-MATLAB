function [argStruct]=Import_argsTemplate(level,projectStruct,subName,trialName,repNum)

%% PURPOSE: TEMPLATE FOR IMPORT ARGUMENTS FUNCTIONS

% Inputs:
% level: The level of the arguments to return (char)
% projectStruct: The entire project's data (struct)
% subName: The current subject's name (char)
% trialName: The current trial's name (char)
% repNum: The repetition number (double)

% Outputs:
% argStruct: The arguments for this level (struct). Each field name is one argument, whether input or output.

switch level
    case 'Project'

    case 'Subject'

    case 'Trial'
        argStruct.Placeholder='placeHolder';
end