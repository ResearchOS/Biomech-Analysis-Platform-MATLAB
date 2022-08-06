function []=fcnDescriptionTextAreaValueChanged(src,event)

%% PURPOSE: STORE THE DESCRIPTION OF THE CURRENT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    return;
end

desc=handles.Process.fcnDescriptionTextArea.Value;

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
varNames=whos('-file',projectSettingsMATPath);
varNames={varNames.name};
if ismember('Digraph',varNames)
    load(projectSettingsMATPath,'Digraph');
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

Digraph.Nodes.Descriptions{nodeRow}=desc;

save(projectSettingsMATPath,'Digraph','-append');