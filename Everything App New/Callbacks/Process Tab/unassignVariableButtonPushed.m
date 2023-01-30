function []=unassignVariableButtonPushed(src,event)

%% PURPOSE: UNASSIGN VARIABLE FROM CURRENT PROCESSING FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currTab=handles.Tabs.tabGroup1.SelectedTab.Title;

switch currTab
    case 'Process'
        motherUITree=handles.Process.groupUITree;
        daughterUITree=handles.Process.functionUITree;    
        daughterClass='Process';
        motherClass='ProcessGroup';
    case 'Plot'
        motherUITree=handles.Plot.plotUITree;
        daughterUITree=handles.Plot.componentUITree;
        daughterClass='Component';
        motherClass='Plot';
    case 'Stats'

end

daughterNode=daughterUITree.SelectedNodes;

if isempty(daughterNode)
    return;
end

if isequal(daughterNode.Parent,daughterUITree)
    disp('Must select an individual argument, not the getArg/setArg parent node!');
    return;
end

spaceIdx=strfind(daughterNode.Text,' ');
if isempty(spaceIdx)
    return; % No argument assigned.
end

% Get the ID number for which getArg/setArg is currently being modified.
parentNode=daughterNode.Parent;
parentText=parentNode.Text;
spaceSplit=strsplit(parentText,' ');
number=str2double(spaceSplit{2});

% Get the index of the current getArg/setArg in the UI tree, which
% matches the index in the file.
childrenNodes=[daughterUITree.Children];
childrenNodesTexts={childrenNodes.Text};
argType=parentNode.Text(1:6);
argSpecificIdx=contains(childrenNodesTexts,argType);
argIdxNum=find(ismember(childrenNodes(argSpecificIdx), parentNode)==1);

% Get the index of the arg being modified in that getArg/setArg
% instance.
idxNum=find(ismember(parentNode.Children,daughterNode)==1);

varPath=getClassFilePath(daughterNode.Text(spaceIdx+2:end-1),'Variable');
varStruct=loadJSON(varPath);

motherNode=motherUITree.SelectedNodes;

daughterPath=getClassFilePath(motherNode.Text,daughterClass);
daughterStruct=loadJSON(daughterPath);

% Remove the currently selected variable from that arg.
if isequal(currTab,'Process')
    if isequal(parentText(1:6),'getArg')
        fldName='InputVariables';
        idx=ismember(varStruct.InputToProcess,daughterStruct.Text);
        varStruct.InputToProcess(idx)=[];
    elseif isequal(parentText(1:6),'setArg')
        fldName='OutputVariables';
        idx=ismember(varStruct.OutputOfProcess,daughterStruct.Text);
        varStruct.OutputOfProcess(idx)=[];
    end
else
    fldName='InputVariables';
end

% Check that I'm removing things from the right place
assert(isequal(daughterStruct.(fldName){argIdxNum}{1},number));

daughterStruct.(fldName){argIdxNum}{idxNum+1}='';

daughterNode.Text=daughterNode.Text(1:spaceIdx-1);

unlinkClasses(varStruct, daughterStruct);