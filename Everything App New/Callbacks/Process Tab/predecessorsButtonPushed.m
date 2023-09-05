function []=predecessorsButtonPushed(src,event)

%% PURPOSE: ADD OR REMOVE PREDECESSORS IN THE VIEW

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

G = getappdata(fig,'viewG');
markerSize = getappdata(fig,'markerSize');
selIdx = markerSize == 8;

if ~any(selIdx)
    return;
end

str = 'add';
add = true;
if contains(handles.Process.predecessorsButton.Text,'-')
    str = 'remove';
    add = false;
end

allG = getappdata(fig,'digraph');
selNodes = G.Nodes.Name(selIdx);

prop = true;
a = questdlg('Propagate the changes upstream?','Propagate?','Yes','No','Cancel','Cancel');
if isempty(a) || isequal(a,'Cancel')
    return;
end
if isequal(a,'No')
    prop = false;
end

preds = {};
for i=1:length(selNodes)
    preds = [preds; predecessors(allG,selNodes{i})];
end

predNames = getName(preds);

predStr = cell(size(preds));
for i=1:length(preds)
    predStr{i} = [predNames{i} ' (' preds{i}];
end

[idx, tf] = listdlg('ListString',predStr,'PromptString',['Select PR to ' str],'SelectionMode','multiple');
if ~tf
    return;
end

preds = preds(idx);

if prop
    R = getDeps(allG, 'up', preds);
    predsIdx = ismember(allG.Nodes.Name,preds);
    predNodesIdx = any(logical(R(predsIdx,:)),1); % The indices of the selected nodes
    preds = allG.Nodes.Name(predNodesIdx);
end

if add
    newPredIdx = ~ismember(preds,G.Nodes.Name);
else
    newPredIdx = ismember(preds,G.Nodes.Name);
end
newPred = preds(newPredIdx); % The potential new nodes to add/remove.

if isequal(str,'add')
    addNodesToView(fig,newPred);
elseif isequal(str,'remove')
    removeNodesFromView(fig,newPred);
end

Current_View = getCurrent('Current_View');
G = filterGraph(fig, Current_View);

renderGraph(fig, G);