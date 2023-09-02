function []=successorsButtonPushed(src,event)

%% PURPOSE: ADD OR REMOVE THE SUCCESSORS OF THE SELECTED NODE(S) IN THE DIGRAPH.

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
if contains(handles.Process.successorsButton.Text,'-')
    str = 'remove';
    add = false;
end

allG = getappdata(fig,'digraph');
selNodes = G.Nodes.Name(selIdx);

succ = {};
for i=1:length(selNodes)
    succ = [succ; successors(allG,selNodes{i})];
end

if add
    newSuccIdx = ~ismember(succ,G.Nodes.Name);
else
    newSuccIdx = ismember(succ,G.Nodes.Name);
end
newSucc = succ(newSuccIdx); % The potential new nodes to add/remove.

newSuccNames = getName(newSucc);

succStr = cell(size(newSucc));
for i=1:length(newSucc)
    succStr{i} = [newSuccNames{i} ' (' newSucc{i}];
end

[idx, tf] = listdlg('ListString',succStr,'PromptString',['Select PR to ' str],'SelectionMode','multiple');
if ~tf
    return;
end

newSucc = newSucc(idx);

if isequal(str,'add')
    addNodesToView(fig,newSucc);
elseif isequal(str,'remove')
    removeNodesFromView(fig,newSucc);
end

Current_View = getCurrent('Current_View');
G = filterGraph(fig, Current_View);

renderGraph(fig, G);