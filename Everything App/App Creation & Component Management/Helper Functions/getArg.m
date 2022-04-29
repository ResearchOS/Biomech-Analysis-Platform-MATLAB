function [varargout]=getArg(inputNamesinCode,subName,trialName,repNum)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% inputNamesinCode: The names of the input arguments. Spelling must match the input arguments function (cell array of chars)
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)
% repNum: The repetition number, if accessing trial data. If subject or project level data, not inputted (double)

% Outputs:
% argIn: The argument to pass in to the processing function

st=dbstack;
fcnName=st(2).name; % The name of the calling function.

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

if ~iscell(inputNamesinCode)
    inputNamesinCode={inputNamesinCode}; % There's only one input argument, so make it a cell if not already.
end

fig=evalin('base','gui;');

if ~isempty(repNum) && ~isempty(trialName)
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
elseif ~isempty(subName)
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];
else
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];
end

if exist(matFilePath,'file')~=2
    disp(['No save file found at: ' matFilePath]);
    return;
end

argNames=cell(length(varargin),1);
nArgs=length(varargin);
for i=4:nArgs+3
    argNames{i-3}=inputname(i); % NOTE THE LIMITATION THAT THERE CAN BE NO INDEXING USED IN THE INPUT VARIABLE NAMES
    if isempty(argNames{i-3})
        error(['Argument #' num2str(i) ' (output variable #' num2str(i-3) ') is not a scalar name in ' fcnName ' line #' num2str(st(2).line)]);
    end
end

% methodLetter=getappdata(fig,'methodLetter'); % Get the method letter from the base workspace

varargout=cell(length(inputNamesinCode),1); % Initialize the output variables.

VariablesMetadata=load(matFilePath,'VariablesMetadata'); % Get the metadata for all variables in the MAT file.

for varNum=1:length(inputNamesinCode)

    projectIdx=ismember(VariablesMetadata.ProjectName,getappdata(fig,'projectName'));
    analysisIdx=ismember(VariablesMetadata.AnalysisName,getappdata(fig,'analysisName'));
    fcnIdx=ismember(VariablesMetadata.OutputFunctionName,getappdata(fig,'fcnName')); % Includes method number & letter
    varsIdx=ismember(VariablesMetadata.NameInCode,inputNamesinCode{varNum});

    currIdx=projectIdx & analysisIdx & fcnIdx & varsIdx; % The idx for the current variable to load.

    if sum(currIdx)==1 % Exactly one variable found. Correct!
        saveName=VariablesMetadata.NameInMAT{currIdx};
        varargout{varNum}=load(matFilePath,'-mat',saveName);
    elseif ~any(currIdx) % No vars found, data not saved.
        nameInGUI=VariablesMetadata.NameInGUI{currIdx};
        error(['Variable ''' nameInGUI ''' missing from file: ' matFilePath]);
%         return;
    elseif sum(currIdx)>1 % Multiple vars found. Should never happen, because setArg should check for this and throw an error!
        nameInGUI=VariablesMetadata.NameInGUI{currIdx};
        error(['Variable ''' nameInGUI ''' found ''' num2str(sum(currIdx)) ''' times in file: ' matFilePath]);
%         return;
    else % What happened here?
        error('What happened here?');
%         return;
    end

end