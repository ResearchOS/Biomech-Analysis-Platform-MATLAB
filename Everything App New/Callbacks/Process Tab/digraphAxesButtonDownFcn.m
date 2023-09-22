function []=digraphAxesButtonDownFcn(src, uuid)

%% PURPOSE: SELECT OR DE-SELECT A NODE IN THE UI AXES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

isMulti = false;
if isequal(fig.Name,'pgui')
    ax = handles.Process.digraphAxes;
    isMulti = handles.Process.multiSelectButton.Value;
    G = getappdata(fig,'viewG');
    popupAx = '';
    isPopup = false;
else
    ax = findobj(fig,'Type','Axes');
    popupAx = ax;
    G = ax.UserData.G;
    isPopup = true;
end

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

nodeClicked = false; % Because the digraph wasn't clicked, it's just being updated. OR no node was clicked on.


if nargin == 1 || isempty(uuid)
    listClicked = false;
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
        nodeClicked = true; % The selection was made in the digraph, so update the list selection accordingly.
    end
else    
    nodeClicked = true;
    listClicked = true;
    idx = ismember(G.Nodes.Name, uuid);    
end


if ~nodeClicked && ~isMulti
    markerSize = repmat(4,length(G.Nodes.Name),1);
    colors = repmat([0 0.447 0.741],length(G.Nodes.Name),1);    
    uuid = '';
else    
    markerSize = getappdata(fig,'markerSize');
    if isempty(markerSize) || ~isMulti
        markerSize = repmat(4,length(xdata),1);
    end
    if any(idx)
        assert(sum(idx)==1);        
        if markerSize(idx)==4
            markerSize(idx) = 8; % Select
        else
            markerSize(idx) = 4; % Deselect
        end
        
        uuid = G.Nodes.Name{idx};
    end
    colors = repmat([0 0.447 0.741], length(xdata), 1);
    colors(markerSize==8,:) = repmat([0 0 0],sum(markerSize==8),1);

end

renderGraph(fig, G, markerSize, colors, [], popupAx);

if isMulti || isPopup
    return; % Don't do the below changes to GUI if selecting multiple nodes.
end

if ~nodeClicked
    handles.Process.successorsButton.Text = 'S';
    handles.Process.predecessorsButton.Text = 'P';
    % Clear current function UI tree
    % Pass focus to current analysis UI tree, expanding the group that the
    % currently selected node is in.
    if ~listClicked
        handles.Process.subtabCurrent.SelectedTab = handles.Process.currentAnalysisTab;
    end
    selNode = handles.Process.analysisUITree.SelectedNodes;
    if isempty(selNode)
        return;
    end
    [~, list] = getUITreeFromNode(selNode);
    for i=1:length(list)-1
        expand(list(i));
    end
    subTabCurrentSelectionChanged(fig);
    return;
end

% Change the selection in the current UI trees
if ~listClicked
    node = selectNode(handles.Process.analysisUITree, uuid);
    if ~isempty(node)
        scroll(handles.Process.analysisUITree, node);
        analysisUITreeSelectionChanged(fig, uuid);

        handles.Process.subtabCurrent.SelectedTab = handles.Process.currentFunctionTab;
        subTabCurrentSelectionChanged(fig);
    else
        assert(~isempty(uuid));
    end
end

% Update successors & predecessors button
Gall = getappdata(fig,'digraph');
succ = successors(Gall,uuid);
pred = predecessors(Gall,uuid);

signS = '+';
signP = '+';
if all(ismember(succ,G.Nodes.Name))
    signS = '-';
end
if all(ismember(pred,G.Nodes.Name))
    signP = '-';
end

handles.Process.successorsButton.Text = ['S' signS];
handles.Process.predecessorsButton.Text = ['P' signP];

end

function [tolX, tolY] = getDigraphTol(ax)

perc = 0.04; % Percent of the graph that the click must be within next to a node.
xlims = ax.XLim;
ylims = ax.YLim;

tolX = (xlims(2)-xlims(1))*perc; % Now in same units as axes limits.
tolY = (ylims(2)-ylims(1))*perc;

end