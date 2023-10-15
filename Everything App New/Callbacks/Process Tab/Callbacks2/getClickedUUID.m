function [uuid] = getClickedUUID(ax, G)

%% PURPOSE: RETURN THE UUID THAT WAS CLICKED ON IN THE DIGRAPH AXES

fig=ancestor(ax,'figure','toplevel');
handles=getappdata(fig,'handles');

if isempty(ax.Children)
    return; % Do nothing if nothing to be done.
end
assert(length(ax.Children)==1);

currPoint = ax.CurrentPoint(1,1:2);
[xTol, yTol] = getDigraphTol(ax);

h = ax.Children(1);

xdata = h.XData';
ydata = h.YData';

xWins = [xdata-xTol/2 xdata+xTol/2];
yWins = [ydata-yTol/2 ydata+yTol/2];

idx = (currPoint(1)>xWins(:,1) & currPoint(1)<xWins(:,2)) & ...
    (currPoint(2)>yWins(:,1) & currPoint(2)<yWins(:,2));
if sum(idx)>1
    dists = sqrt((xdata-currPoint(1)).^2+(ydata-currPoint(2)).^2);
    [~,minDistIdx] = min(dists);
    assert(ismember(minDistIdx,find(idx==1))); % Only one node found, and it's close to the cursor.
    idx = false(length(xdata),1);
    idx(minDistIdx) = true;
end

if sum(idx)==1
    uuid = G.Nodes.Name(idx);
elseif sum(idx)==0
    uuid = '';
end

if length(uuid)==1
    uuid = uuid{1};
end

end

function [tolX, tolY] = getDigraphTol(ax)

perc = 0.04; % Percent of the graph that the click must be within next to a node.
xlims = ax.XLim;
ylims = ax.YLim;

tolX = (xlims(2)-xlims(1))*perc; % Now in same units as axes limits.
tolY = (ylims(2)-ylims(1))*perc;

end