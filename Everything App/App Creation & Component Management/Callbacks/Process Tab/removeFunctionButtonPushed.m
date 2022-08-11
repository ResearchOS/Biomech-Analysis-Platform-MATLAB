function []=removeFunctionButtonPushed(src,event)

%% PURPOSE: REMOVE THE FUNCTION SELECTED IN THE FCNARGSUITREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

nodeNum=handles.Process.fcnArgsUITree.SelectedNodes.NodeData;

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');

nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

selNodeIDs=getappdata(fig,'selectedNodeNumbers');
selNodeIDs=selNodeIDs(~ismember(selNodeIDs,nodeNum));
setappdata(fig,'selectedNodeNumbers',selNodeIDs);

nodeRowNum=find(nodeRow==1);
Digraph=rmnode(Digraph,nodeRowNum);

save(projectSettingsMATPath,'Digraph','-append');

if isempty(selNodeIDs)
    delete(handles.Process.fcnArgsUITree.Children);
    delete(handles.Process.mapFigure.Children);
    set(handles.Process.mapFigure,'ColorOrderIndex',1);
    plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames);
    return;
end

highlightedFcnsChanged(fig,Digraph,selNodeIDs(1));