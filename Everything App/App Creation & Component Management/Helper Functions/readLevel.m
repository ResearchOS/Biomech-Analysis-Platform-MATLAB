function [levels]=readLevel(fcnPath)

%% PURPOSE: BASED OFF OF THE FIRST LINE OF A FUNCTION, ASCERTAIN THE LEVEL TO CALL THAT FUNCTION AT.
% Inputs:
% fcnPath: The full path name of the function to read (char)

% Outputs:
% levels: The processing levels in the current function (char)

A=regexp(fileread(fcnPath),'\n','split'); % Open the newly created file

firstLine=A{1};
firstLine=firstLine(~isspace(firstLine));

openParensIdx=strfind(firstLine,'(');
closeParensIdx=strfind(firstLine,')');

args=strsplit(firstLine(openParensIdx+1:closeParensIdx-1),',');

switch length(args)
    case 1 % Just projectStruct
        levels='P';
    case 2 % projectStruct and allTrialNames
        if isequal(args{2},'allTrialNames')
            levels='PST';
        else
            levels='PS';
        end
    case 4 % projectStruct, subName, trialName, repNum
        levels='T';
    otherwise
        levels=''; % The user switched up the input variables
end