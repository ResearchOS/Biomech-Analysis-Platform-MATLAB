function []=markImportFcnCheckboxValueChanged(src,event)

%% PURPOSE: INDICATE WHETHER A FUNCTION NODE IS AN IMPORT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    handles.Process.markImportFcnCheckbox.Value=false;
    return;
end

nodeNum=handles.Process.fcnArgsUITree.SelectedNodes.NodeData;

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');

nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

Digraph.Nodes.IsImport(nodeRow)=true;

save(projectSettingsMATPath,'Digraph','-append');