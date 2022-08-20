function []=connectNodesButtonPushedWindowButtonDown(src,event)

%% PURPOSE: CONNECT TWO NODES WITH AN EDGE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

connectNodesCoords=getappdata(fig,'connectNodesCoords');

if all(isnan(connectNodesCoords),'all')
    rowNum=1;
else
    rowNum=2;
end

if ~isequal(handles.Tabs.tabGroup1.SelectedTab.Title,'Process')
    return;
end

if isempty(fig.CurrentObject)
    return;
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% xlims=handles.Process.mapFigure.XLim;
% ylims=handles.Process.mapFigure.YLim;

currPoint=handles.Process.mapFigure.CurrentPoint;

currPoint=currPoint(1,1:2);

connectNodesCoords(rowNum,1:2)=currPoint;

setappdata(fig,'connectNodesCoords',connectNodesCoords);

if rowNum==1
    return;
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph','NonFcnSettingsStruct');

digraphCoords=Digraph.Nodes.Coordinates;
digraphDists1=sqrt((digraphCoords(:,1)-repmat(connectNodesCoords(1,1),size(digraphCoords,1),1)).^2+(digraphCoords(:,2)-repmat(connectNodesCoords(1,2),size(digraphCoords,1),1)).^2);
digraphDists2=sqrt((digraphCoords(:,1)-repmat(connectNodesCoords(2,1),size(digraphCoords,1),1)).^2+(digraphCoords(:,2)-repmat(connectNodesCoords(2,2),size(digraphCoords,1),1)).^2);

[~,idx1]=min(digraphDists1);
[~,idx2]=min(digraphDists2);

if isequal(idx1,idx2)
    disp('Cannot connect a node to itself!');
    setappdata(fig,'connectNodesCoords',NaN(2,2));
    setappdata(fig,'doNothingOnButtonUp',0);
set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
    'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));
    return;
end

sp=shortestpath(Digraph,idx1,idx2);

if ~isempty(sp) && length(sp)>2
    disp('Nodes already connected, cannot have redundant connections except for between neighboring nodes!'); % Redundant connections allowed between neighboring nodes only
    setappdata(fig,'connectNodesCoords',NaN(2,2));
    setappdata(fig,'doNothingOnButtonUp',0);
    set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
        'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));
    return;
end

nodeID1=Digraph.Nodes.NodeNumber(idx1,:);
nodeID2=Digraph.Nodes.NodeNumber(idx2,:);

splitsOrder=getSplitsOrder(handles.Process.splitsUITree.SelectedNodes);
if isempty(splitsOrder)
    return;
end

Digraph=addedge(Digraph,idx1,idx2);

if ~any(ismember(Digraph.Edges.Properties.VariableNames,'FunctionNames'))
    currEdgeIdx=true; % The row number of the function names for the new edge
else
    currEdgeIdx=ismember(Digraph.Edges.EndNodes,[idx1,idx2],'rows') & cellfun(@isempty, Digraph.Edges.FunctionNames(:,1));
end

assert(sum(currEdgeIdx)==1);

Digraph.Edges.FunctionNames{currEdgeIdx,1}=Digraph.Nodes.FunctionNames{idx1};
Digraph.Edges.FunctionNames{currEdgeIdx,2}=Digraph.Nodes.FunctionNames{idx2};
Digraph.Edges.NodeNumber(currEdgeIdx,1)=nodeID1;
Digraph.Edges.NodeNumber(currEdgeIdx,2)=nodeID2;
splitsStruct=NonFcnSettingsStruct.Process.Splits;
for i=1:length(splitsOrder)
    splitsStruct=splitsStruct.SubSplitNames.(splitsOrder{i});
end
color=splitsStruct.Color;
Digraph.Edges.Color(currEdgeIdx,:)=color;

load([getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'RGB XKCD - Custom' slash 'xkcd_rgb_data.mat'],'rgblist');
for i=1:size(Digraph.Edges.Color,1)
    edgeColorsIdx(i)=find(ismember(rgblist,Digraph.Edges.Color(i,:),'rows')==1);
end

% Q=gcf;
% currMap=colormap(gcf);
colormap(rgblist);
% figure(Q);

%% Plot the new connection
delete(handles.Process.mapFigure.Children);
plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.447 0.741],...
    'EdgeCData',edgeColorsIdx);

% colormap(Q,currMap);
save(projectSettingsMATPath,'Digraph','-append');

setappdata(fig,'doNothingOnButtonUp',0);
set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
    'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));