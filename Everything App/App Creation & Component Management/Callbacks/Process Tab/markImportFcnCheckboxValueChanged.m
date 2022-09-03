function []=markImportFcnCheckboxValueChanged(src,nodeNum)

%% PURPOSE: INDICATE WHETHER A FUNCTION NODE IS AN IMPORT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    handles.Process.markImportFcnCheckbox.Value=false;
    return;
end

if exist('nodeNum','var')~=1
    nodeNum=handles.Process.fcnArgsUITree.SelectedNodes.NodeData;
    runLog=true;
else
    handles.Process.fcnArgsUITree.SelectedNodes=findobj(handles.Process.fcnArgsUITree,'NodeData',nodeNum);
    runLog=false;
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');

nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

Digraph.Nodes.IsImport(nodeRow)=true;

save(projectSettingsMATPath,'Digraph','-append');

if runLog
    desc='Marked function as import';
    updateLog(fig,desc,nodeNum);
end