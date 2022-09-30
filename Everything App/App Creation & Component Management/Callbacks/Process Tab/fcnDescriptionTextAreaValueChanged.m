function []=fcnDescriptionTextAreaValueChanged(src,fcnDesc,nodeNum)

%% PURPOSE: STORE THE DESCRIPTION OF THE CURRENT FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    return;
end

if exist('fcnDesc','var')~=1
    fcnDesc=handles.Process.fcnDescriptionTextArea.Value;
    runLog=true;
else
    handles.Process.fcnDescriptionTextArea.Value=fcnDesc;
    runLog=false;
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
varNames=whos('-file',projectSettingsMATPath);
varNames={varNames.name};
if ismember('Digraph',varNames)
%     load(projectSettingsMATPath,'Digraph');
    Digraph=getappdata(fig,'Digraph');
end

if runLog
nodeNum=handles.Process.fcnArgsUITree.SelectedNodes.NodeData;
else
    handles.Process.fcnArgsUITree.SelcetedNodes=findobj(handles.Process.fcnArgsUITree,'NodeData',nodeNum);
end
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

Digraph.Nodes.Descriptions{nodeRow}=fcnDesc;

% save(projectSettingsMATPath,'Digraph','-append');
setappdata(fig,'Digraph',Digraph);

if runLog
    desc='Changed function description';
    updateLog(fig,desc,fcnDesc,nodeNum);
end