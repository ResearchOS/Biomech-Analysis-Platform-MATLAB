function []=assignExistingArg2OutputButtonPushed(src,event)

%% PURPOSE:

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    disp('Select a function first!');
    return;
end

if isequal(handles.Process.varsListbox.Items,{'No Vars'})
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
namesInCode=VariableNamesList.SaveNames(varRow);

for i=1:length(varNameInGUI)
    currName=varNameInGUI{i};
    nameInCode=namesInCode{i};

    if ismember(currName,Digraph.Nodes.OutputVariableNames{nodeRow})
        disp(['No Args Added. Variable ''' currName ''' Already in Function ''' Digraph.Nodes.FunctionNames{nodeRow} '''']);
        return;
    end

    Digraph.Nodes.OutputVariableNames{nodeRow}=[Digraph.Nodes.OutputVariableNames{nodeRow}; currName];
    Digraph.Nodes.OutputVariableNamesInCode{nodeRow}=[Digraph.Nodes.OutputVariableNamesInCode{nodeRow}; nameInCode];

    emptyIdx=cellfun(@isempty,Digraph.Nodes.OutputVariableNames{nodeRow});

    Digraph.Nodes.OutputVariableNames{nodeRow}=Digraph.Nodes.OutputVariableNames{nodeRow}(~emptyIdx);
    Digraph.Nodes.OutputVariableNamesInCode{nodeRow}=Digraph.Nodes.OutputVariableNamesInCode{nodeRow}(~emptyIdx);

    b=findobj(a,'Text','Outputs');

    newNode=uitreenode(b,'Text',currName);

    if i==1
        handles.Process.fcnArgsUITree.SelectedNodes=newNode;
        handles.Process.argNameInCodeField.Value=nameInCode;
    end

%     highlightedFcnsChanged(fig,Digraph,nodeNum);

end
expand(b);

save(projectSettingsMATPath,'Digraph','-append');