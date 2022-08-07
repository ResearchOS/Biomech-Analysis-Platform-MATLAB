function setArg(subName,trialName,repNum,varargin)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% STORES THE VARIABLE FIRST INTO THE PROJECTSTRUCT, THEN SAVES IT TO THE CORRESPONDING MAT FILE.
% Inputs:
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)
% repNum: The repetition number for the current trial (double)
% varargin: The value of each output argument. The name passed in to this function must exactly match what is in the input arguments function (any data type)

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

%% Get the level for the current arguments to store. Also get the file path for the current MAT file.
fig=evalin('base','gui;');
projectName=getappdata(fig,'projectName');
if ~isempty(repNum) && ~isempty(trialName) % Trial level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
elseif ~isempty(subName) % Subject level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];
else % Project level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];
end

%% Get the names of the setArg input arguments. Checks if they are valid names.
argNames=cell(length(varargin),1);
nArgs=length(varargin);
for i=4:nArgs+3
    argNames{i-3}=inputname(i); % NOTE THE LIMITATION THAT THERE CAN BE NO INDEXING USED IN THE INPUT VARIABLE NAMES
    if isempty(argNames{i-3})
        error(['Argument #' num2str(i) ' (output variable #' num2str(i-3) ') is not a scalar name in ' fcnName ' line #' num2str(st(2).line)]);
    end
end

splitCode=getappdata(fig,'splitCode');

load(getappdata(fig,'projectSettingsMATPath'),'Digraph','VariableNamesList');

nodeRow=getappdata(fig,'nodeRow');
varNamesInCode=Digraph.Nodes.OutputVariableNamesInCode{nodeRow}; 
currVarsIdx=ismember(varNamesInCode,argNames); % Get the idx of the output var names being output currently
guiVarNames=Digraph.Nodes.OutputVariableNames{nodeRow}(currVarsIdx); % The names of the variables as seen in the GUI
varNamesIdx=ismember(VariableNamesList.GUINames,guiVarNames); % The idx in the VariableNamesList of the current variables
saveNames=VariableNamesList.SaveNames(varNamesIdx);

for i=1:length(saveNames)
    saveNames{i}=[saveNames{i} '_' splitCode];
end

for i=1:length(saveNames)
    eval([saveNames{i} '=varargin{' num2str(i) '};']);
end

folder=fileparts(matFilePath);

if exist(folder,'dir')~=7
    mkdir(folder);
end

if exist(matFilePath,'file')~=2
    save(matFilePath,saveNames{:});
else
    save(matFilePath,saveNames{:},'-append');
end