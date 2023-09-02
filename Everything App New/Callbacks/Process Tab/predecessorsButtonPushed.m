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

pred = {};
for i=1:length(selNodes)
    pred = [pred; predecessors(allG,selNodes{i})];
end

if add
    newPredIdx = ~ismember(pred,G.Nodes.Name);
else
    newPredIdx = ismember(pred,G.Nodes.Name);
end
newPred = pred(newPredIdx); % The potential new nodes to add/remove.

newPredNames = getName(newPred);

predStr = cell(size(newPred));
for i=1:length(newPred)
    predStr{i} = [newPredNames{i} ' (' newPred{i}];
end

[idx, tf] = listdlg('ListString',predStr,'PromptString',['Select PR to ' str],'SelectionMode','multiple');
if ~tf
    return;
end

newPred = newPred(idx);

if isequal(str,'add')
    addNodesToView(fig,newPred);
elseif isequal(str,'remove')
    removeNodesFromView(fig,newPred);
end

Current_View = getCurrent('Current_View');
G = filterGraph(fig, Current_View);

renderGraph(fig, G);