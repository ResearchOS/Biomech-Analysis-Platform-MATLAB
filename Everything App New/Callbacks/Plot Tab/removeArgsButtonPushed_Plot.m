function []=removeArgsButtonPushed_Plot(src,event)

%% PURPOSE: REMOVE ARGS FROM PLOT COMPONENT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Plot.componentUITree.SelectedNodes;

if isempty(selNode)
    return;
end

if ~isequal(selNode.Parent,handles.Plot.componentUITree)
    disp('Must select getArg/setArg node!');
    return;
end

% Get the index of the current getArg/setArg in the UI tree, which
% matches the index in the file.
childrenNodes=[handles.Plot.componentUITree.Children];
childrenNodesTexts={childrenNodes.Text};
argType=selNode.Text(1:6);
argSpecificIdx=contains(childrenNodesTexts,argType);
argIdxNum=find(ismember(childrenNodes(argSpecificIdx), selNode)==1);

componentNode=handles.Plot.plotUITree.SelectedNodes;
componentPath=getClassFilePath(componentNode.Text, 'Component', fig);
componentStruct=loadJSON(componentPath);

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
assert(isequal(componentStruct.(fldName){argIdxNum}{1},number));

% Unlink each variable from the componentStruct
for i=2:length(componentStruct.(fldName){argIdxNum})

    if isempty(componentStruct.(fldName){argIdxNum}{i})
        continue;
    end

    varPath=getClassFilePath(componentStruct.(fldName){argIdxNum}{i},'Variable', fig);
    varStruct=loadJSON(varPath);
    unlinkClasses(fig, varStruct, componentStruct);
end

% Remove the getArg/setArg from the processStruct, and do the same in the
% PI project struct.
componentStruct.(fldName)(argIdxNum)=[];

piText=getPITextFromPS(componentStruct.Text);
piComponentPath=getClassFilePath(piText,'Component', fig);
piStruct=loadJSON(piComponentPath);

piStruct.(fldNamePI)(argIdxNum)=[];

writeJSON(componentPath,componentStruct);
writeJSON(piComponentPath,piStruct);

delete(selNode);