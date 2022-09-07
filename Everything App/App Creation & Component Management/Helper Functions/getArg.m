function [varargout]=getArg(inputNamesInCode,subName,trialName,repNum)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% FIRST LOOKS THROUGH VARS EXISTING IN THE WORKSPACE. IF NOT FOUND THERE, SEARCHES IN THE CORRESPONDING MAT FILE. IF NOT FOUND THERE, THROWS ERROR.
% Inputs:
% inputNamesinCode: The names of the input arguments. Spelling must match the input arguments function (cell array of chars)
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)
% repNum: The repetition number, if accessing trial data. If subject or project level data, not inputted (double)

% Outputs:
% argIn: The argument to pass in to the processing function

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

if exist('trialName','var')~=1
    trialName='';
end
if exist('repNum','var')~=1
    repNum='';
end
if exist('subName','var')~=1
    subName='';
end

if ~iscell(inputNamesInCode)
    inputNamesInCode={inputNamesInCode}; % There's only one input argument, so make it a cell if not already.
end

if length(inputNamesInCode)~=length(unique(inputNamesInCode))
    beep;
    disp('Argument names in code must be unique!');
    return;
end

try
    fig=evalin('base','gui;');
    isRunCode=0;
catch
    try
        fig=evalin('base','runCodeGUI;');
        isRunCode=1;
    catch
        disp('Missing the GUI!');
        return;
    end
end

nodeRow=getappdata(fig,'nodeRow');

projectName=getappdata(fig,'projectName');

if ~isempty(repNum) && ~isempty(trialName) % Trial level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
elseif ~isempty(subName) % Subject level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];
else % Project level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];
end

if isRunCode==0
    Digraph=getappdata(fig,'Digraph');
    VariableNamesList=getappdata(fig,'VariableNamesList');
    if isempty(Digraph) || isempty(VariableNamesList)
        load(getappdata(fig,'projectSettingsMATPath'),'Digraph','VariableNamesList');
    end
else
    try
        VariableNamesList=evalin('base','VariableNamesList;');
        Digraph=evalin('base','Digraph;');
    catch
        disp('Missing settings variables from the base workspace!');
        return;
    end
end

splitName=getappdata(fig,'splitName');
splitCode=getappdata(fig,'splitCode');

%% All input vars
% The idx/subset of the variables currently being accessed
[~,~,currVarsIdx]=intersect(inputNamesInCode,Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode]),'stable');
try
    assert(isequal(Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode])(currVarsIdx)',inputNamesInCode));
catch
    a=inputNamesInCode(~ismember(inputNamesInCode,Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode])(currVarsIdx)'));
    disp(a);
    error('Check your input variable names in code!');
end
% [~,a,currVarsIdx]=intersect(inputNamesInCode,Digraph.Nodes.InputVariableNamesInCode{nodeRow}.([splitName '_' splitCode]),'stable');
% The GUI names of the variables currently being accessed (in the order of the inputNamesInCode).
inputVarNamesInGUI_Split=Digraph.Nodes.InputVariableNames{nodeRow}.([splitName '_' splitCode])(currVarsIdx);
inputVarNamesInGUI=cell(size(inputVarNamesInGUI_Split));
varSplits=cell(size(inputVarNamesInGUI));
for i=1:length(inputVarNamesInGUI_Split)
    inputVarNamesInGUI{i}=inputVarNamesInGUI_Split{i}(1:end-6); % Remove the split code
    varSplits{i}=inputVarNamesInGUI_Split{i}(end-3:end-1); % In the order of the inputNamesInCode
end

[~,~,varRowsIdxNums]=intersect(inputVarNamesInGUI,VariableNamesList.GUINames,'stable'); % The rows in the VariableNamesList matrix of the variables currently being accessed
assert(isequal(inputVarNamesInGUI,VariableNamesList.GUINames(varRowsIdxNums)));
saveNames=VariableNamesList.SaveNames(varRowsIdxNums); % The save names of all vars in inputNamesInCode (in the same order)

varargout=cell(length(inputNamesInCode),1); % Initialize the output variables.

%% Hard-coded variables
hardCodedStatus=VariableNamesList.IsHardCoded(varRowsIdxNums);
hardCodedIdxNums=find(cellfun(@isequal,hardCodedStatus,repmat({1},length(hardCodedStatus),1))==1); % The idx of hard-coded vars (in the order of the inputNamesInCode)
hardCodedSaveNames=saveNames(hardCodedIdxNums);

if ~isempty(hardCodedIdxNums)
    folderName=[getappdata(fig,'codePath') 'Hard-Coded Variables'];
    oldPath=cd(folderName);

    for i=1:length(hardCodedSaveNames)

        % Get .m full file path and ensure that it exists
        varName=hardCodedSaveNames{i};
        splitCodeVar=varSplits{hardCodedIdxNums(i)};
        varargout{hardCodedIdxNums(i)}=feval([varName '_' splitCodeVar]);

    end
    cd(oldPath);
end

%% Dynamic variables
dynamicIdxNums=find(cellfun(@isequal,hardCodedStatus,repmat({0},length(hardCodedStatus),1))==1);
if isempty(dynamicIdxNums)
    return;
end
dynamicSaveNames=saveNames(dynamicIdxNums);

for i=1:length(dynamicSaveNames)
    splitCodeVar=varSplits{dynamicIdxNums(i)};
    dynamicSaveNames{i}=[dynamicSaveNames{i} '_' splitCodeVar];
end

try
    S=load(matFilePath,'-mat',dynamicSaveNames{:});
catch
    if exist(matFilePath,'file')~=2
        disp(['No saved file found at: ' matFilePath]);
        return;
    end

    fileVarNames=whos('-file',matFilePath);
    fileVarNames={fileVarNames.name};

    if ~all(ismember(dynamicSaveNames,fileVarNames))
        disp('Missing variables in mat file!'); % Specify which variables
        return;
    end
end

for i=1:length(dynamicSaveNames)
    varargout{dynamicIdxNums(i)}=S.(dynamicSaveNames{i}); % This requires copying variables, which is inherently slow. Faster way?
end