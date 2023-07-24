function []=digraphAxesButtonDownFcn(src,event)

%% PURPOSE: SELECT OR DE-SELECT A NODE IN THE UI AXES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Old code snippets
% currPoint=handles.Process.mapFigure.CurrentPoint;
% h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'Interpreter','none');
% if ~isempty(Digraph.Edges)
%     h.EdgeColor=Digraph.Edges.Color;
% end

% h=findobj(handles.Process.mapFigure,'Type','GraphPlot');
% delete(h);
% set(handles.Process.mapFigure,'ColorOrderIndex',1);

% For selecting a node
% allDots=getappdata(fig,'allDots');
% 
%     allCoords=[allDots.XData' allDots.YData'];
% 
%     allCoordsDists=sqrt((allCoords(:,1)-repmat(currPoint(1,1),size(allCoords,1),1)).^2+(allCoords(:,2)-repmat(currPoint(1,2),size(allCoords,1),1)).^2);
% 
%     [~,I]=min(allCoordsDists);
% 
%     newNodeCoord=allCoords(I,:);
% 
%     delete(allDots);
%     setappdata(fig,'allDots','');