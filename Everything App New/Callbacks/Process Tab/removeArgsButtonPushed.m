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
processUUID = processNode.NodeData.UUID;
processStruct = loadJSON(processUUID);

argSpaceIdx=strfind(selNode.Text,' ');
number=str2double(selNode.Text(argSpaceIdx+1:end));

switch argType
    case 'getArg'
        fldNameInst='InputVariables';
        fldNameSub='InputSubvariables';
        fldNameAbs='InputVariablesNamesInCode';
    case 'setArg'
        fldNameInst='OutputVariables';
        fldNameAbs='OutputVariablesNamesInCode';
end

% Check that I'm putting things in the right place
% assert(isequal(processStruct.(fldNameInst){argIdxNum}{1},number));

% Unlink each variable from the processStruct
% for i=2:length(processStruct.(fldNameInst){argIdxNum})
% 
%     if isempty(processStruct.(fldNameInst){argIdxNum}{i})
%         continue;
%     end
% 
%     varPath=getClassFilePath(processStruct.(fldNameInst){argIdxNum}{i},'Variable');
%     varStruct=loadJSON(varPath);
% %     unlinkClasses(varStruct, processStruct);
% end

% Remove the getArg/setArg from the processStruct, and do the same in the
% PI project struct.
processStruct.(fldNameInst)(argIdxNum)=[];
if isequal(argType,'getArg')
    processStruct.(fldNameSub)(argIdxNum)=[];
end

[type, abstractID] = deText(processStruct.UUID);
abstractUUID = genUUID(type, abstractID);
absStruct = loadJSON(abstractUUID);

absStruct.(fldNameAbs)(argIdxNum)=[];

writeJSON(getJSONPath(processStruct),processStruct);
writeJSON(getJSONPath(absStruct),absStruct);

delete(selNode);