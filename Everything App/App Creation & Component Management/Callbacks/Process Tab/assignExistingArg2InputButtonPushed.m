function []=assignExistingArg2InputButtonPushed(src,event)

%% PURPOSE: ASSIGN A VARIABLE FROM THE ALL VARS LIST TO THE CURRENT FUNCTION AS INPUT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    disp('Select a function first!');
    return;
end

if isequal(handles.Process.varsListbox.Items,{'No Vars'})
    disp('Create a variable first!');
    return;
end

if isequal(handles.Process.fcnArgsUITree.SelectedNodes.Text,'Logsheet')
    disp('Cannot add variables to the logsheet!');
    return;
end

varNameInGUI=handles.Process.varsListbox.Value;

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
namesInCode=VariableNamesList.SaveNames(varRow); % The default name in code

for i=1:length(varNameInGUI)
    currName=varNameInGUI{i};
    nameInCode=namesInCode{i};

    if ismember(currName,Digraph.Nodes.InputVariableNames{nodeRow})
        disp(['No Args Added. Variable ''' currName ''' Already in Function ''' Digraph.Nodes.FunctionNames{nodeRow} '''']);
        return;
    end

    Digraph.Nodes.InputVariableNames{nodeRow}=[Digraph.Nodes.InputVariableNames{nodeRow}; currName];
    Digraph.Nodes.InputVariableNamesInCode{nodeRow}=[Digraph.Nodes.InputVariableNamesInCode{nodeRow}; nameInCode];

    emptyIdx=cellfun(@isempty,Digraph.Nodes.InputVariableNames{nodeRow});

    Digraph.Nodes.InputVariableNames{nodeRow}=Digraph.Nodes.InputVariableNames{nodeRow}(~emptyIdx);
    Digraph.Nodes.InputVariableNamesInCode{nodeRow}=Digraph.Nodes.InputVariableNamesInCode{nodeRow}(~emptyIdx);

    b=findobj(a,'Text','Inputs');

    newNode=uitreenode(b,'Text',currName);

    if i==1
        handles.Process.fcnArgsUITree.SelectedNodes=newNode;
        handles.Process.argNameInCodeField.Value=nameInCode;
    end

%     highlightedFcnsChanged(fig,Digraph,nodeNum);

end

expand(b);

save(projectSettingsMATPath,'Digraph','-append');