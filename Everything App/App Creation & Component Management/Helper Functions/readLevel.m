function [levels]=readLevel(fcnPath,isImport)

%% PURPOSE: BASED OFF OF THE FIRST LINE OF A FUNCTION, ASCERTAIN THE LEVEL TO CALL THAT FUNCTION AT.
% Inputs:
% fcnPath: The full path name of the function to read (char)
% isImport: 1 if the function imports from some file type to .mat, 0 if not
% (logical)

% Outputs:
% levels: The processing levels in the current function (char)

A=regexp(fileread(fcnPath),'\n','split'); % Open the newly created file

firstLine=A{1};
firstLine=firstLine(~isspace(firstLine));

openParensIdx=strfind(firstLine,'(');
closeParensIdx=strfind(firstLine,')');

args=strsplit(firstLine(openParensIdx+1:closeParensIdx-1),',');

if isequal(args,{'projectStruct'})
    levels='P';
elseif isequal(args,{'projectStruct','subNames'})
    levels='PS';
elseif isequal(args,{'projectStruct','allTrialNames'})
    levels='PST';
elseif isequal(args,{'projectStruct','subName','trialNames'})
    levels='ST';
elseif isequal(args,{'projectStruct','subName'}) % How to distinguish between PS and S?
    levels='S';
elseif isequal(args,{'projectStruct','subName','trialName','repNum'})
    levels='T';
else
    levels=''; % The user changed the input variables
end

if isequal(levels,'')
    disp('The input arguments were changed! Here are the list of available input arguments:');
    disp('Project: ''projectStruct''');
    disp('Project & Subject: ''projectStruct, subNames''');
    disp('Project, Subject, & Trial: ''projectStruct, subName, trialNames''');
    disp('Subject & Trial: ''projectStruct, subName, trialNames''');
    disp('Subject: ''projectStruct, subName''');
    disp('Trial: ''projectStruct, subName, trialName, repNum''');
end

if isImport
    levels='T'; % Easy version for now
end