function []=removeFunctionButtonPushed(src,nodeNum)

%% PURPOSE: REMOVE THE FUNCTION SELECTED IN THE FCNARGSUITREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(handles.Process.fcnArgsUITree.SelectedNodes)
    disp('Select a node in the function arguments UI tree first!');
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

if nodeRow(1)
    disp('Cannot delete the logsheet node, that is the origin node!');
    return; % Logsheet node was selected
end

selNodeIDs=getappdata(fig,'selectedNodeNumbers');
selNodeIDs=selNodeIDs(~ismember(selNodeIDs,nodeNum));
setappdata(fig,'selectedNodeNumbers',selNodeIDs);

nodeRowNum=find(nodeRow==1);
Digraph=rmnode(Digraph,nodeRowNum);

save(projectSettingsMATPath,'Digraph','-append');

if isempty(selNodeIDs)
    delete(handles.Process.fcnArgsUITree.Children);
    delete(handles.Process.mapFigure.Children);
%     set(handles.Process.mapFigure,'ColorOrderIndex',1);
    h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.447 0.741],'Interpreter','none');
    h.EdgeColor=Digraph.Edges.Color;
    return;
end

highlightedFcnsChanged(fig,Digraph,selNodeIDs(1));

if runLog
    desc='Removed a function node';
    updateLog(fig,desc,nodeNum);
end