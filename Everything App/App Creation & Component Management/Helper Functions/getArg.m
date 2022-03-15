function [varargout]=getArg(argNames,subName,trialName,repNum)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% argNames: The names of the input arguments. Spelling must match the input arguments function (cell array of chars)
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)

% Outputs:
% argIn: The argument to pass in to the processing function

if ~iscell(argNames)
    argNames={argNames}; % There's only one input argument, so make it a cell if not already.
end

fig=evalin('base','gui;');

% if nargin<=3 % Trial level data. No repetitions
%     repNum=1;
% end
% if nargin<=2 % Subject level data
%     trialName='';
% end
% if nargin==1 % Project level data
%     subName='';
% end

% 1. Get the name of the corresponding input argument file
% fig=evalin('base','gui;'); % Get the gui from the base workspace.
st=dbstack;
fcnName=st(2).name; % The name of the calling function.
methodLetter=getappdata(fig,'methodLetter'); % Get the method letter from the base workspace
guiTab=getappdata(fig,'guiTab');

%% Relate the argNames to the arg function names
[text]=readAllArgsTextFile(getappdata(fig,'everythingPath'),getappdata(fig,'projectName'),getappdata(fig,'guiTab'));
[argsFcnNames,argsNamesInCode]=getAllArgNames(text,getappdata(fig,'projectName'),guiTab,getappdata(fig,'groupName'),[fcnName methodLetter]);

argsFcnName=cell(length(argNames),1);
argCount=0;
for j=1:length(argNames)
    for i=1:length(argsNamesInCode)

        currArgNameInCode=argsNamesInCode{i};
        currArgNameSplit=strsplit(currArgNameInCode,',');
        beforeCommaSplit=strsplit(currArgNameSplit{1},' ');
        %     afterCommaSplit=strsplit(currArgNameSplit{2},' ');

        if isequal(beforeCommaSplit{1},'0') && isequal(beforeCommaSplit{2},argNames{j})
            argCount=argCount+1;
            argsFcnName{argCount}=[guiTab 'Arg_' argsFcnNames{i}];
        end

    end
end

% idx=ismember(argsFcnNames,argNames);
% argsNamesInCode=argsNamesInCode(idx);
% argsNamesInCode=argsNamesInCode(idx);

% useGroupArgs=0; % 1 to use group args, 0 not to. This will be replaced by GUI checkbox value later.
% if useGroupArgs==1 % Group level arguments
%
% else
%     %     argsFunc=[argsFolder slash fcnName methodLetter '_' argNames]; % The full path to the arguments file
%     argsFuncName=[fcnName methodLetter];
% end

if evalin('base','exist(''projectStruct'',''var'')~=1')
    evalin('base','projectStruct='''''); % If there's no projectStruct, create an empty one. Why though? Shouldn't I return an error?
end

varargout=cell(length(argNames),1);

assert(length(argNames)==length(argsFcnName));
for i=1:length(argNames)

    % argIn returned as a struct with fields of argNames
    if exist('trialName','var')
%         level='Trial';
        [~,argIn]=feval(argsFcnName{i},evalin('base','projectStruct;'),subName,trialName,repNum);
    elseif exist('subName','var')
%         level='Subject';
        [~,argIn]=feval(argsFcnName{i},evalin('base','projectStruct;'),subName);
    else
%         level='Project';
        [~,argIn]=feval(argsFcnName{i},evalin('base','projectStruct;'));
    end

    varargout{i}=argIn;

end

% Find the subset of arguments specified by argNames
% retArgNames=fieldnames(argIn);

% for i=1:length(argNames)
%
%     if isfield(argIn,argNames{i})
%         varargout{i}=argIn.(argNames{i}); % All argument names should have been found in the arguments function!
%     end
%
% end

