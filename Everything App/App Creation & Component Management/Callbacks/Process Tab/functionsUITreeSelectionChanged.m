function []=functionsUITreeSelectionChanged(src,event)

%% PURPOSE: DO SOMETHING WHEN A SPECIFIC NODE IN THE FUNCTIONS UI TREE OBJECT IS SELECTED. I.E. SHOW PROPER DESCRIPTION, ETC.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
varNames=whos('-file',projectSettingsMATPath);
varNames={varNames.name};
assert(ismember('Digraph',varNames));

load(projectSettingsMATPath,'Digraph');

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    handles.Process.fcnDescriptionTextArea.Value='Enter Arg Description Here';
    return;
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

handles.Process.fcnDescriptionTextArea.Value=Digraph.Nodes.Descriptions{nodeRow};