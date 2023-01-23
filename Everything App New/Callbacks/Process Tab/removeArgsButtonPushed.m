function []=removeArgsButtonPushed(src,event)

%% PURPOSE:

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.functionUITree.SelectedNodes;

if isempty(selNode)
    return;
end

if ~isequal(selNode.Parent,handles.Process.functionUITree)
    disp('Must select getArg/setArg node!');
    return;
end

% Get the index of the current getArg/setArg in the UI tree, which
% matches the index in the file.
childrenNodes=[handles.Process.functionUITree.Children];
childrenNodesTexts={childrenNodes.Text};
argType=selNode.Text(1:6);
argSpecificIdx=contains(childrenNodesTexts,argType);
argIdxNum=find(ismember(childrenNodes(argSpecificIdx), selNode)==1);

processNode=handles.Process.groupUITree.SelectedNodes;
processPath=getClassFilePath(processNode.Text, 'Process', fig);
processStruct=loadJSON(processPath);

argSpaceIdx=strfind(selNode.Text,' ');
number=str2double(selNode.Text(argSpaceIdx+1:end));

switch argType
    case 'getArg'
        fldName='InputVariables';
        fldNamePI='InputVariablesNamesInCode';
    case 'setArg'
        fldName='OutputVariables';
        fldNamePI='OutputVariablesNamesInCode';
end

% Check that I'm putting things in the right place
assert(isequal(processStruct.(fldName){argIdxNum}{1},number));

% Unlink each variable from the processStruct
for i=2:length(processStruct.(fldName){argIdxNum})

    if isempty(processStruct.(fldName){argIdxNum}{i})
        continue;
    end

    varPath=getClassFilePath(processStruct.(fldName){argIdxNum}{i},'Variable', fig);
    varStruct=loadJSON(varPath);
    unlinkClasses(fig, varStruct, processStruct);
end

% Remove the getArg/setArg from the processStruct, and do the same in the
% PI project struct.
processStruct.(fldName)(argIdxNum)=[];

piText=getPITextFromPS(processStruct.Text);
piProcessPath=getClassFilePath(piText,'Process', fig);
piStruct=loadJSON(piProcessPath);

piStruct.(fldNamePI)(argIdxNum)=[];

writeJSON(processPath,processStruct);
writeJSON(piProcessPath,piStruct);

delete(selNode);