function []=unassignVariableButtonPushed(src,event)

%% PURPOSE: UNASSIGN VARIABLE FROM CURRENT PROCESSING FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

argNode=handles.Process.functionUITree.SelectedNodes;

if isempty(argNode)
    return;
end

if isequal(argNode.Parent,handles.Process.functionUITree)
    disp('Must select an individual argument, not the getArg/setArg parent node!');
    return;
end

spaceIdx=strfind(argNode.Text,' ');
if isempty(spaceIdx)
    return; % No argument assigned.
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

varPath=getClassFilePath(argNode.Text(spaceIdx+2:end-1),'Variable',fig);
varStruct=loadJSON(varPath);

processNode=handles.Process.groupUITree.SelectedNodes;

processPath=getClassFilePath(processNode.Text,'Process',fig);
processStruct=loadJSON(processPath);

% Remove the currently selected variable from that arg.
if isequal(parentText(1:6),'getArg')
    fldName='InputVariables';
    idx=ismember(varStruct.InputToProcess,processStruct.Text);
    varStruct.InputToProcess(idx)=[];
elseif isequal(parentText(1:6),'setArg')
    fldName='OutputVariables';
    idx=ismember(varStruct.OutputOfProcess,processStruct.Text);
    varStruct.OutputOfProcess(idx)=[];
end

% Check that I'm removing things from the right place
assert(isequal(processStruct.(fldName){argIdxNum}{1},number));

processStruct.(fldName){argIdxNum}{idxNum+1}='';

argNode.Text=argNode.Text(1:spaceIdx-1);

unlinkClasses(fig, varStruct, processStruct);