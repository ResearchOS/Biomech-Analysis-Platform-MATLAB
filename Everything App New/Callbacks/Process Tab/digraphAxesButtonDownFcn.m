function []=digraphAxesButtonDownFcn(src, uuid)

%% PURPOSE: SELECT OR DE-SELECT A NODE IN THE UI AXES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

ax = handles.Process.digraphAxes;

if isempty(ax.Children)
    return; % Do nothing if nothing to be done.
end
assert(length(ax.Children)==1);

% bool = isDoubleClick(ax);

currPoint = ax.CurrentPoint(1,1:2);
[xTol, yTol] = getDigraphTol(ax);

h = ax.Children(1);

xdata = h.XData';
ydata = h.YData';

xWins = [xdata-xTol/2 xdata+xTol/2];
yWins = [ydata-yTol/2 ydata+yTol/2];

G = getappdata(fig,'digraph');
if nargin == 1 || isempty(uuid)
    idx = (currPoint(1)>xWins(:,1) & currPoint(1)<xWins(:,2)) & ...
    (currPoint(2)>yWins(:,1) & currPoint(2)<yWins(:,2));
    doSelectionChanged = true; % The selection was made in the digraph, so update the list selection accordingly.
    if sum(idx)>1
        dists = sqrt((xdata-currPoint(1)).^2+(ydata-currPoint(2)).^2);
        [~,minDistIdx] = min(dists);
        assert(ismember(minDistIdx,find(idx==1))); % Only one node found, and it's close to the cursor.
        idx = false(length(xdata),1);
        idx(minDistIdx) = true;
    end
else    
    idx = ismember(G.Nodes.Name, uuid);
    doSelectionChanged = false; % Because the digraph wasn't clicked, it's just being updated.
end
if ~any(idx)
    markerSize = repmat(4,length(G.Nodes.Name),1);
    colors = repmat([0 0.447 0.741],length(G.Nodes.Name),1);
    groupSelNode = handles.Process.groupUITree.SelectedNodes;
    if isempty(groupSelNode)
        uuid = '';
    else
        uuid = groupSelNode.NodeData.UUID;
    end
else
    assert(sum(idx)==1);

    markerSize = repmat(4,length(xdata),1);
    markerSize(idx) = 8;

    colors = repmat([0 0.447 0.741], length(xdata), 1);
    colors(idx,:) = [0 0 0];    
    uuid = G.Nodes.Name{idx};   

end

renderGraph(fig, [], markerSize, colors);

if ~doSelectionChanged
    return;
end

% Change the selection in the current UI trees
selectNode(handles.Process.analysisUITree, uuid);
analysisUITreeSelectionChanged(fig, uuid);

handles.Process.subtabCurrent.SelectedTab = handles.Process.currentFunctionTab;

end

function [tolX, tolY] = getDigraphTol(ax)

perc = 0.08; % Percent of the graph that the click must be within next to a node.
xlims = ax.XLim;
ylims = ax.YLim;

tolX = (xlims(2)-xlims(1))*perc; % Now in same units as axes limits.
tolY = (ylims(2)-ylims(1))*perc;

end