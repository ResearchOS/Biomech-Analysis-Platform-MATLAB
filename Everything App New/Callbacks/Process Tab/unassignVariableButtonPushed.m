function []=unassignVariableButtonPushed(src,event)

%% PURPOSE: UNASSIGN VARIABLE FROM CURRENT PROCESSING FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% Current process group UI tree
currFcnNode = handles.Process.groupUITree.SelectedNodes;

if isempty(currFcnNode)
    return;
end

% Current process UI tree
processUITree=handles.Process.functionUITree; 

currVarNode=processUITree.SelectedNodes;

if isempty(currVarNode)
    return;
end

currVarUUID = currVarNode.NodeData.UUID;

parentNode = currVarNode.Parent;
if isequal(parentNode,processUITree)
    disp('Must select an individual argument, not the getArg/setArg parent node!');
    return;
end

getSetArgIdxNum = str2double(parentNode.Text(isstrprop(parentNode.Text,'digit'))); % Number of this getArg or setArg

if isequal(parentNode.Text(1:6),'getArg')
    fldName = 'InputVariables';
elseif isequal(parentNode.Text(1:6),'setArg')
    fldName = 'OutputVariables';
end

currFcnUUID = currFcnNode.NodeData.UUID;
fcnStruct = loadJSON(currFcnUUID);

getSetArgIdx = [];
for i=1:length(fcnStruct.(fldName))
    if isequal(fcnStruct.(fldName){i}{1},getSetArgIdxNum)
        getSetArgIdx = i;
        break;
    end
end
assert(~isempty(getSetArgIdx));

argIdx = ismember(fcnStruct.(fldName){getSetArgIdx}(2:end),currVarUUID); % Get which argument this is.
argIdx = [false; argIdx];
fcnStruct.(fldName){getSetArgIdx}(argIdx) = {''};
if isequal(fldName,'InputVariables')
    fcnStruct.InputSubvariables{getSetArgIdx}(argIdx) = {''}; % Changing the variable, so the subvariable should be reset.
end
writeJSON(getJSONPath(fcnStruct), fcnStruct);

currVarNode.NodeData.UUID = '';
argTextSplit = strsplit(currVarNode.Text);
currVarNode.Text = argTextSplit{1};















spaceIdx=strfind(currVarNode.Text,' ');
if isempty(spaceIdx)
    return; % No argument assigned.
end

% Get the ID number for which getArg/setArg is currently being modified.
parentNode=currVarNode.Parent;
parentText=parentNode.Text;
spaceSplit=strsplit(parentText,' ');
number=str2double(spaceSplit{2});

% Get the index of the current getArg/setArg in the UI tree, which
% matches the index in the file.
childrenNodes=[processUITree.Children];
childrenNodesTexts={childrenNodes.Text};
argType=parentNode.Text(1:6);
argSpecificIdx=contains(childrenNodesTexts,argType);
argIdxNum=find(ismember(childrenNodes(argSpecificIdx), parentNode)==1);

% Get the index of the arg being modified in that getArg/setArg
% instance.
idxNum=find(ismember(parentNode.Children,currVarNode)==1);

varPath=getClassFilePath(currVarNode.Text(spaceIdx+2:end-1),'Variable');
varStruct=loadJSON(varPath);

motherNode=motherUITree.SelectedNodes;

daughterPath=getClassFilePath(motherNode.Text,daughterClass);
daughterStruct=loadJSON(daughterPath);

% Remove the currently selected variable from that arg.
if isequal(currTab,'Process')
    if isequal(parentText(1:6),'getArg')
        fldName='InputVariables';
        idx=ismember(varStruct.ForwardLinks_Process,daughterStruct.Text);
        varStruct.ForwardLinks_Process(idx)=[];
    elseif isequal(parentText(1:6),'setArg')
        fldName='OutputVariables';
        idx=ismember(varStruct.BackwardLinks_Process,daughterStruct.Text);
        varStruct.BackwardLinks_Process(idx)=[];
    end
else
    fldName='InputVariables';
end

% Check that I'm removing things from the right place
assert(isequal(daughterStruct.(fldName){argIdxNum}{1},number));

daughterStruct.(fldName){argIdxNum}{idxNum+1}='';

currVarNode.Text=currVarNode.Text(1:spaceIdx-1);

unlinkClasses(varStruct, daughterStruct);