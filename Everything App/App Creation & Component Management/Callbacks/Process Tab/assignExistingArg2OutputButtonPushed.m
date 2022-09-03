function []=assignExistingArg2OutputButtonPushed(src,event,nodeNum,varNameInGUI,splitCode)

%% PURPOSE:

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    disp('Select a function first!');
    return;
end

if isempty(handles.Process.varsListbox.Children)
    disp('Create a variable first!');
    return;
end

if isequal(handles.Process.fcnArgsUITree.SelectedNodes.Text,'Logsheet')
    disp('Cannot add variables to the logsheet!');
    return;
end

if isequal(class(handles.Process.varsListbox.SelectedNodes.Parent),'matlab.ui.container.Tree')
    beep;
    disp('Must select a specific split from this variable!');
    return;
end

splitText=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(splitText,' ');
fcnSplitName=splitText(1:spaceIdx-1);
fcnSplitCode=splitText(spaceIdx+2:end-1);

varNameInGUI=handles.Process.varsListbox.SelectedNodes.Parent.Text;
varText=handles.Process.varsListbox.SelectedNodes.Text;
varSpaceIdx=strfind(varText,' ');
varSplitName=varText(1:varSpaceIdx-1);
varSplitCode=varText(varSpaceIdx+2:end-1);

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
varNames=whos('-file',projectSettingsMATPath);
varNames={varNames.name};
assert(ismember('Digraph',varNames));

if ~ismember('VariableNamesList',varNames)
    load(projectSettingsMATPath,'Digraph');
else
    load(projectSettingsMATPath,'Digraph','VariableNamesList');
end

nodeNum=handles.Process.fcnArgsUITree.SelectedNodes.NodeData;
a=handles.Process.fcnArgsUITree.SelectedNodes;
for i=1:2
    if ~isempty(nodeNum)
        break;
    end
    a=a.Parent;
    nodeNum=a.NodeData;
end

assert(~isempty(nodeNum));

nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

varRow=ismember(VariableNamesList.GUINames,varNameInGUI); % The row of the variable names of interest
namesInCode=VariableNamesList.SaveNames{varRow};

currName=varNameInGUI;
nameInCode=namesInCode;

outVarNames=Digraph.Nodes.OutputVariableNames{nodeRow}.([fcnSplitName '_' fcnSplitCode]);
outVarNamesInCode=Digraph.Nodes.OutputVariableNamesInCode{nodeRow}.([fcnSplitName '_' fcnSplitCode]);

currName=[currName ' (' fcnSplitCode ')']; % Append the code for the split that the variable is going to.

if ismember(currName,outVarNames)
    disp(['No Args Added. Variable ''' currName ''' Already in Function ''' Digraph.Nodes.FunctionNames{nodeRow} '''']);
    return;
end

if isempty(outVarNames)
    outVarNames={currName};
    outVarNamesInCode={nameInCode};
else
    outVarNames=[outVarNames; {currName}];
    outVarNamesInCode=[outVarNamesInCode; {nameInCode}];
end

Digraph.Nodes.OutputVariableNames{nodeRow}.([fcnSplitName '_' fcnSplitCode])=outVarNames;
Digraph.Nodes.OutputVariableNamesInCode{nodeRow}.([fcnSplitName '_' fcnSplitCode])=outVarNamesInCode;

b=findobj(a,'Text','Outputs');

newNode=uitreenode(b,'Text',currName);

handles.Process.fcnArgsUITree.SelectedNodes=newNode;
% handles.Process.argNameInCodeField.Value=nameInCode;

expand(b);

save(projectSettingsMATPath,'Digraph','-append');

functionsUITreeSelectionChanged(fig);