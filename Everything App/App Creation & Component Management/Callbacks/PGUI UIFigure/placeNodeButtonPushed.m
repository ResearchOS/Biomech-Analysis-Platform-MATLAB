function []=placeNodeButtonPushed(src,currPoint)

%% PURPOSE: THE PLACE FCN WAS PUSHED, WHICH REQUIRES CLICKING ON THE UIAXES, SO THE WINDOWBUTTONDOWN FCN WAS CHANGED TO THIS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if ~isequal(handles.Tabs.tabGroup1.SelectedTab.Title,'Process')
    return;
end

if isempty(fig.CurrentObject)
    return;
end

if exist('currPoint','var')~=1
    currPoint=handles.Process.mapFigure.CurrentPoint;
    currPoint=currPoint(1,1:2);
    runLog=true;
else
    runLog=false;
end

xlims=handles.Process.mapFigure.XLim;
ylims=handles.Process.mapFigure.YLim;

if ~(currPoint(1)>=xlims(1) && currPoint(1)<=xlims(2) && currPoint(2)>=ylims(1) && currPoint(2)<=ylims(2)) % Ensure the cursor is within the uiaxes
    disp('Must place the function node within the axes limits! Click elsewhere');    
    return;
end

if exist('currPoint','var')==1

    allDots=getappdata(fig,'allDots');

    allCoords=[allDots.XData' allDots.YData'];

    allCoordsDists=sqrt((allCoords(:,1)-repmat(currPoint(1,1),size(allCoords,1),1)).^2+(allCoords(:,2)-repmat(currPoint(1,2),size(allCoords,1),1)).^2);

    [~,I]=min(allCoordsDists);

    newNodeCoord=allCoords(I,:);

    delete(allDots);
    setappdata(fig,'allDots','');
    
    runLog=true;
else
    runLog=false;
    newNodeCoord=round(currPoint);
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'Digraph');
Digraph=getappdata(fig,'Digraph');

if ismember(newNodeCoord,Digraph.Nodes.Coordinates,'rows')
    disp('Cannot place a function node on top of an existing node! Click elsewhere');
    return;
end

% Add most node properties
Digraph=addnode(Digraph,1);

fcnName=getappdata(fig,'placeFcnName');
setappdata(fig,'placeFcnName','');
Digraph.Nodes.FunctionNames{end}=fcnName;
Digraph.Nodes.Descriptions{end}={''};
Digraph.Nodes.Coordinates(end,:)=newNodeCoord;
Digraph.Nodes.InputVariableNames{end}='';
Digraph.Nodes.OutputVariableNames{end}='';
% Digraph.Nodes.SplitCodes{end}={splitCode};
Digraph.Nodes.SpecifyTrials{end}='';
currNodeID=max(Digraph.Nodes.NodeNumber)+1;
Digraph.Nodes.NodeNumber(end)=currNodeID; % Helps to differentiate nodes of the same function name
Digraph.Nodes.InputVariableNamesInCode{end}=''; % Name in file/code
Digraph.Nodes.OutputVariableNamesInCode{end}=''; % Name in file/code
Digraph.Nodes.IsImport(end)=false;

h=findobj(handles.Process.mapFigure,'Type','GraphPlot');
delete(h);
set(handles.Process.mapFigure,'ColorOrderIndex',1);
h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'Interpreter','none');
if ~isempty(Digraph.Edges)
    h.EdgeColor=Digraph.Edges.Color;
end

% save(projectSettingsMATPath,'Digraph','-append');
setappdata(fig,'Digraph',Digraph);

setappdata(fig,'doNothingOnButtonUp',1);
set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
    'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));

if runLog
    desc='Inserted new function node';
    updateLog(fig,desc);
end