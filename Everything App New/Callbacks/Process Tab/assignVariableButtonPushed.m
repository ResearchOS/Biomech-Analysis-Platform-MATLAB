function []=assignVariableButtonPushed(src,event)

%% PURPOSE: ASSIGN VARIABLE TO CURRENT PROCESSING FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% All variables UI tree
selNode=handles.Process.allVariablesUITree.SelectedNodes;

if isempty(selNode)
    return;
end

% Current group UI tree
processNode=handles.Process.groupUITree.SelectedNodes;

if isempty(processNode)
    return;
end

% Current function UI tree
argNode=handles.Process.functionUITree.SelectedNodes;

if isempty(argNode)
    return;
end

if isequal(argNode.Parent,handles.Process.functionUITree)
    disp('Must select an individual argument, not the getArg/setArg parent node!');
    return;
end

% Determine whether to create a new project-specific variable version or
% use an existing one.
if isequal(selNode.Parent,handles.Process.allVariablesUITree)
    isNew=true;
else
    isNew=false;
end

% Get the currently selected PS process struct
fullPath=getClassFilePath_PS(processNode.Text, 'Process', fig);
processStruct=loadJSON(fullPath);

% Check if argNode already has a variable assigned. If so, need to unlink
% that variable from the process function
if contains(argNode.Text,' ')
    spaceIdx=strfind(argNode.Text,' ');
    varText=argNode.Text(spaceIdx+2:end-1);
    prevVarPath=getClassFilePath(varText, 'Variable', fig);
    prevVarStruct=loadJSON(prevVarPath);
    [prevVarStruct, processStruct]=unlinkClasses(fig, prevVarStruct, processStruct);
end

% Get the ID number for which getArg/setArg is currently being modified.
parentNode=argNode.Parent;
parentText=parentNode.Text;
spaceSplit=strsplit(parentText,' ');
number=str2double(spaceSplit{2});

% Get the index of the current getArg/setArg in the UI tree, which
% matches the index in the file.
childrenNodes=[handles.Process.functionUITree.Children];
childrenNodesTexts={childrenNodes.Text};
argType=parentNode.Text(1:6);
argSpecificIdx=contains(childrenNodesTexts,argType);
argIdxNum=find(ismember(childrenNodes(argSpecificIdx), parentNode)==1);

% Get the index of the arg being modified in that getArg/setArg
% instance.
idxNum=find(ismember(parentNode.Children,argNode)==1);

switch isNew
    case true
        % Create a new project-specific ID for the variable to add.
        varPath=getClassFilePath(selNode);
        varStructPI=loadJSON(varPath);
        varStruct=createVariableStruct_PS(fig,varStructPI);
    case false
        varPath=getClassFilePath_PS(selNode.Text, 'Variable', fig);
        varStruct=loadJSON(varPath);
end

% Apply the currently selected variable to that arg.
if isequal(parentText(1:6),'getArg')
    fldName='InputVariables';
    varStruct.InputToProcess=unique([varStruct.InputToProcess; {processStruct.Text}]);
elseif isequal(parentText(1:6),'setArg')
    fldName='OutputVariables';
    varStruct.OutputOfProcess=unique([varStruct.OutputOfProcess; {processStruct.Text}]);
end

if ~iscell(processStruct.(fldName)) || ...
        (iscell(processStruct.(fldName)) && (length(processStruct.(fldName))<argIdxNum || isempty(processStruct.(fldName){argIdxNum})))
    processStruct.(fldName){argIdxNum}{1}=number;
end

% Check that I'm putting things in the right place
assert(isequal(processStruct.(fldName){argIdxNum}{1},number));

processStruct.(fldName){argIdxNum}{idxNum+1}=varStruct.Text;

% Saves changes.
linkClasses(fig, varStruct, processStruct); % Create a connection between the variable & the process function

% Save changes
% saveClass_PS(fig, 'Process', processStruct);
% saveClass_PS(fig, 'Variable', varStruct);

% Modify/add nodes
argTextSplit=strsplit(argNode.Text,' ');
argText=[argTextSplit{1} ' (' varStruct.Text ')'];
argNode.Text=argText;

if isNew
    uitreenode(selNode,'Text',varStruct.Text,'ContextMenu',handles.Process.psContextMenu);
end