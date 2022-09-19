function []=disconnectNodesButtonPushedWindowButtonDown(src,disconnectNodesCoords)

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('disconnectNodesCoords','var')~=1
    disconnectNodesCoords=getappdata(fig,'disconnectNodesCoords');

    if all(isnan(disconnectNodesCoords),'all')
        rowNum=1;
    else
        rowNum=2;
    end

    currPoint=handles.Process.mapFigure.CurrentPoint;

    currPoint=currPoint(1,1:2);

    disconnectNodesCoords(rowNum,1:2)=currPoint;

    runLog=true;

    xlims=handles.Process.mapFigure.XLim;
    ylims=handles.Process.mapFigure.YLim;

    if currPoint(1)<xlims(1) || currPoint(1)>xlims(2) || currPoint(2)<ylims(1) || currPoint(2)>ylims(2)
        setappdata(fig,'disconnectNodesCoords',NaN(2,2));
        setappdata(fig,'doNothingOnButtonUp',0); % Allows functions to be highlighted as normal.
        set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
            'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));
        %     disp('Clicked outside of the axes');
        return; % Clicked outside of the axes
    end

else
    runLog=false;
end

if ~isequal(handles.Tabs.tabGroup1.SelectedTab.Title,'Process')
    return;
end

if isempty(fig.CurrentObject)
    return;
end

setappdata(fig,'disconnectNodesCoords',disconnectNodesCoords);

if rowNum==1
    return; % First click
end

setappdata(fig,'disconnectNodesCoords',NaN(2,2));

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'Digraph','NonFcnSettingsStruct');
Digraph=getappdata(fig,'Digraph');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');

digraphCoords=Digraph.Nodes.Coordinates;
digraphDists1=sqrt((digraphCoords(:,1)-repmat(disconnectNodesCoords(1,1),size(digraphCoords,1),1)).^2+(digraphCoords(:,2)-repmat(disconnectNodesCoords(1,2),size(digraphCoords,1),1)).^2);
digraphDists2=sqrt((digraphCoords(:,1)-repmat(disconnectNodesCoords(2,1),size(digraphCoords,1),1)).^2+(digraphCoords(:,2)-repmat(disconnectNodesCoords(2,2),size(digraphCoords,1),1)).^2);

[~,idx1]=min(digraphDists1);
[~,idx2]=min(digraphDists2);

if isequal(idx1,idx2)
    disp('No need to disconnect a node from itself!');
    setappdata(fig,'disconnectNodesCoords',NaN(2,2));
    setappdata(fig,'doNothingOnButtonUp',0);
    set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
        'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));
    return;
end

sp=shortestpath(Digraph,idx1,idx2); % Is this directional?

%% HERE NEED TO PROMPT THE USER TO ASK WHICH SPLIT SHOULD BE REMOVED.
if isempty(Digraph.Edges)
    disp('No edges to remove!');
    return;
end
edgeRows=ismember(Digraph.Edges.EndNodes,[idx1 idx2],'rows');
splitCodes=Digraph.Edges.SplitCode(edgeRows);

if runLog
    badCode=1;
    while badCode==1

        Q=uifigure('Name','Select Split to Remove');
        Qhandles.uitree=uitree(Q,'checkbox','Tag','Tree');
        okbox=uibutton(Q,'push','Text','OK','Position',[450 200 100 50],'ButtonPushedFcn',@(Q,event) okButtonPushedSplits(Q));
        Qhandles.okbox=okbox;
        setappdata(Q,'handles',Qhandles);

        rootTag='Stop';
        rootNode=uitreenode(Qhandles.uitree,'Text','Root (Not a Split)','Tag',rootTag);

        splitsStruct=NonFcnSettingsStruct.Process.Splits;
        getSplitNames(splitsStruct,[],rootNode);
        uiwait(Q);
        try
            selSplit=evalin('base','selSplit;'); % 1st entry is the root split, last entry is the split to branch off of.
        catch
            return; % The process was aborted.
        end
        evalin('base','clear selSplit;');

        selSplit=selSplit(~ismember(selSplit,'Root'));

        if isempty(selSplit)
            disp('Root node is not a valid split, try again!');
            continue;
        end

        name=selSplit{end};
        selSplit=selSplit(~ismember(selSplit,name));

        splitCode=genSplitCode(fig,projectSettingsMATPath,selSplit,name); % Need to alter genSplitCode to be recursive

        if ~ismember({splitCode},splitCodes)
            disp('Must select a split with an arrow pointing towards the second node selected');
            continue;
        end

        badCode=0;

    end
end

if isempty(sp) || ~all(ismember(sp,[idx1 idx2]))
    disp('No connections to undo!');
    setappdata(fig,'disconnectNodesCoords',NaN(2,2));
    setappdata(fig,'doNothingOnButtonUp',0);
    set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
        'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));
    return;
end

nodeID1=Digraph.Nodes.NodeNumber(idx1,:);
nodeID2=Digraph.Nodes.NodeNumber(idx2,:);

if isempty(Digraph.Edges)
    newDigraph=digraph;
    for i=1:size(Digraph.Nodes,1)
        newDigraph=addnode(newDigraph,Digraph.Nodes(i,:));
    end
    Digraph=newDigraph;
end

edgeIdx=find((ismember(Digraph.Edges.SplitCode,splitCode) & ismember(Digraph.Edges.NodeNumber,[nodeID1 nodeID2],'rows'))==1);
Digraph=rmedge(Digraph,edgeIdx);

%% NOW I AM KEEPING ALL VARIABLES FOR ALL SPLITS SO THAT DISCONNECTING AND RE-CONNECTING A NODE FROM A SPLIT DOES NOT DELETE ITS VARIABLES.

%% Plot the new plot.
h=findobj(handles.Process.mapFigure,'Type','GraphPlot');
delete(h);
h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.447 0.741],'Interpreter','none');
h.EdgeColor=Digraph.Edges.Color;

% save(projectSettingsMATPath,'Digraph','-append');
setappdata(fig,'Digraph',Digraph);

setappdata(fig,'doNothingOnButtonUp',0);

highlightedFcnsChanged(fig,Digraph);

if runLog
    set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
        'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));
else

end