function [varargout]=getArg(inputNamesinCode,subName,trialName,repNum)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% inputNamesinCode: The names of the input arguments. Spelling must match the input arguments function (cell array of chars)
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)

% Outputs:
% argIn: The argument to pass in to the processing function

if ~iscell(inputNamesinCode)
    inputNamesinCode={inputNamesinCode}; % There's only one input argument, so make it a cell if not already.
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

%% Relate the inputNamesinCode to the arg function names
[text]=readAllArgsTextFile(getappdata(fig,'everythingPath'),getappdata(fig,'projectName'),getappdata(fig,'guiTab'));
[argsFcnNames,refArgsNamesInCode]=getAllArgNames(text,getappdata(fig,'projectName'),guiTab,getappdata(fig,'groupName'),[fcnName methodLetter]);

argsFcnName=cell(length(inputNamesinCode),1);
argCount=0;
argNotFoundIdx=[];
for j=1:length(inputNamesinCode)
    argFound=0;
    for i=1:length(refArgsNamesInCode)

        currArgNameInCode=refArgsNamesInCode{i};
        currArgNameSplit=strsplit(currArgNameInCode,',');
        beforeCommaSplit=strsplit(currArgNameSplit{1},' ');
        %     afterCommaSplit=strsplit(currArgNameSplit{2},' ');

        if isequal(beforeCommaSplit{1},'0') && isequal(beforeCommaSplit{2},inputNamesinCode{j})
            argFound=1;
            argCount=argCount+1;
            argsFcnName{argCount}=[guiTab 'Arg_' argsFcnNames{i}];
        end
    end
    if argFound==0
        warning(['Argument Not Found: ' inputNamesinCode{j}]);        
        argCount=argCount+1;
        argNotFoundIdx=[argNotFoundIdx argCount];
        return;
    end
end

if evalin('base','exist(''projectStruct'',''var'')~=1')
    evalin('base','projectStruct='''''); % If there's no projectStruct, create an empty one. Why though? Shouldn't I return an error?
end

varargout=cell(length(inputNamesinCode),1);

% assert(length(inputNamesinCode)==length(argsFcnName));
for i=1:length(inputNamesinCode)

%     if ismember(i,argNotFoundIdx)
%         varargout{i}='Not Found';
%         continue; % This argument was somehow not found, so skipping it.
%     end

    % argIn returned as a struct with fields of inputNamesinCode
    if exist('trialName','var')
%         level='Trial';
        [argIn]=feval(argsFcnName{i},'in',evalin('base','projectStruct;'),subName,trialName,repNum);
    elseif exist('subName','var')
%         level='Subject';
        [argIn]=feval(argsFcnName{i},'in',evalin('base','projectStruct;'),subName,'','');
    else
%         level='Project';
        [argIn]=feval(argsFcnName{i},'in',evalin('base','projectStruct;'),'','','');
    end    

    varargout{i}=argIn;

end

% Find the subset of arguments specified by inputNamesinCode
% retArgNames=fieldnames(argIn);

% for i=1:length(inputNamesinCode)
%
%     if isfield(argIn,inputNamesinCode{i})
%         varargout{i}=argIn.(inputNamesinCode{i}); % All argument names should have been found in the arguments function!
%     end
%
% end

