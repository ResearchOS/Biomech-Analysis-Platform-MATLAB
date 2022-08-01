function []=assignExistingArg2InputButtonPushed(src,event)

%% PURPOSE: ASSIGN A VARIABLE FROM THE ALL VARS LIST TO THE CURRENT FUNCTION AS INPUT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    disp('Select a function first!');
    return;
end

varNameInGUI=handles.Process.varsListbox.Value;

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
varNames=whos('-file',projectSettingsMATPath);
varNames={varNames.name};
assert(ismember('Digraph',varNames));

load(projectSettingsMATPath,'Digraph');

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

for i=1:length(varNameInGUI)
    currName=varNameInGUI{i};

    if ismember(currName,Digraph.Nodes.InputVariableNames{nodeRow})
        disp(['No Args Added. Variable ''' currName ''' Already in Function ''' Digraph.Nodes.FunctionNames{nodeRow} '''']);
        return;
    end

    Digraph.Nodes.InputVariableNames{nodeRow}=[Digraph.Nodes.InputVariableNames{nodeRow}; currName];

    emptyIdx=cellfun(@isempty,Digraph.Nodes.InputVariableNames{nodeRow});

    Digraph.Nodes.InputVariableNames{nodeRow}=Digraph.Nodes.InputVariableNames{nodeRow}(~emptyIdx);

    highlightedFcnsChanged(fig,Digraph,nodeNum);

end

expand(a);

save(projectSettingsMATPath,'Digraph','-append');