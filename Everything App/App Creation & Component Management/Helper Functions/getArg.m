function [varargout]=getArg(inputNamesinCode,subName,trialName,repNum)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% FIRST LOOKS THROUGH VARS EXISTING IN THE WORKSPACE. IF NOT FOUND THERE, SEARCHES IN THE CORRESPONDING MAT FILE. IF NOT FOUND THERE, THROWS ERROR.
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

if length(inputNamesinCode)~=length(unique(inputNamesinCode))
    beep;
    disp('Argument names in code must be unique!');
    return;
end

fig=evalin('base','gui;');

nodeRow=getappdata(fig,'nodeRow');

projectName=getappdata(fig,'projectName');

if ~isempty(repNum) && ~isempty(trialName) % Trial level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
elseif ~isempty(subName) % Subject level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];
else % Project level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];
end

if exist(matFilePath,'file')~=2
    disp(['No saved file found at: ' matFilePath]);
    return;
end

load(getappdata(fig,'projectSettingsMATPath'),'Digraph','VariableNamesList');

fileVarNames=whos('-file',matFilePath);
fileVarNames={fileVarNames.name};

currVarsIdx=ismember(Digraph.Nodes.InputVariableNamesInCode{nodeRow},inputNamesinCode); % The idx of the variables currently being accessed
inputVarNamesInGUI=Digraph.Nodes.InputVariableNames{nodeRow}(currVarsIdx); % The GUI names of the variables currently being accessed.
varRows=ismember(VariableNamesList.GUINames,inputVarNamesInGUI); % The rows in the VariableNamesList matrix of the variables currently being accessed

hardCodedIdx=cellfun(@isequal,VariableNamesList.IsHardCoded,repmat({1},length(VariableNamesList.IsHardCoded),1)) & varRows==1; % The indices in the VariableNamesList matrix of the variables currently being accessed
hardCodedVarNamesInGUI=VariableNamesList.GUINames(hardCodedIdx); % The names of the hard-coded variables currently being accessed.
hardCodedVarNamesIdx=ismember(Digraph.Nodes.InputVariableNames{nodeRow},hardCodedVarNamesInGUI); % The idx of the Digraph fcn input variables currently being accessed
hardCodedNamesInCode=Digraph.Nodes.InputVariableNamesInCode{nodeRow}(hardCodedVarNamesIdx); % The names in code of the hard-coded variables being accessed
hardCodedInputIdx=ismember(inputNamesinCode,hardCodedNamesInCode); % The idx of the variables (in the inputNamesinCode) that are hard-coded
hardCodedSaveNames=VariableNamesList.SaveNames(hardCodedIdx); % The save name of the hard-coded variable. This is how the .m file was named.

dynamicIdx=cellfun(@isequal,VariableNamesList.IsHardCoded,repmat({0},length(VariableNamesList.IsHardCoded),1)) & varRows==1;
dynamicVarNamesInGUI=VariableNamesList.GUINames(dynamicIdx);
dynamicVarNamesIdx=ismember(Digraph.Nodes.InputVariableNames{nodeRow},dynamicVarNamesInGUI);
dynamicNamesInCode=Digraph.Nodes.InputVariableNamesInCode{nodeRow}(dynamicVarNamesIdx);
dynamicInputIdx=ismember(inputNamesinCode,dynamicNamesInCode);
dynamicSaveNames=VariableNamesList.SaveNames(dynamicIdx);

% Check that all hard-coded variables have existing .m files
hardCodedInputIdxNums=find(hardCodedInputIdx==1);
folderName=[getappdata(fig,'codePath') 'Hard-Coded Variables'];
oldPath=cd(folderName);
% splitName=handles.Process.splitsUITree.SelectedNodes.Text;
splitCode=getappdata(fig,'splitCode');
% splitCode=NonFcnSettingsStruct.Process.Splits.(splitName).Code;
for i=1:length(hardCodedSaveNames)

    % Get .m full file path and ensure that it exists
    idx=hardCodedInputIdxNums(i);    
    varargout{idx}=feval([hardCodedSaveNames{i} '_' splitCode]);

end
cd(oldPath);

if isempty(dynamicSaveNames)
    return;
end

% Append the split code onto the variable name to load from the file
for i=1:length(dynamicSaveNames)
    dynamicSaveNames{i}=[dynamicSaveNames{i} '_' splitCode];
end

% Check that all non-hard-coded variables have existing data in .mat files
if ~all(ismember(dynamicSaveNames,fileVarNames))
    disp('Missing variables in mat file!'); % Specify which variables
    return;
end

S=load(matFilePath,'-mat',dynamicSaveNames{:});

dynamicInputIdx=find(dynamicInputIdx==1);
assert(isequal(sort(dynamicSaveNames),sort(fieldnames(S))));
for i=1:length(dynamicSaveNames)

    inIdx=dynamicInputIdx(i);
    varargout{inIdx}=S.(dynamicSaveNames{i});

end