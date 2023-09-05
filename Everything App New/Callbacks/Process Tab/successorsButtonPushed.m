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

prop = true;
a = questdlg('Propagate the changes downstream?','Propagate','Yes','No','Cancel','Cancel');
if isempty(a) || isequal(a,'Cancel')
    return;
end
if isequal(a,'No')
    prop = false;
end

succs = {};
for i=1:length(selNodes)
    succs = [succs; successors(allG,selNodes{i})];
end

succNames = getName(succs);

succStr = cell(size(succs));
for i=1:length(succs)
    succStr{i} = [succNames{i} ' (' succs{i}];
end

[idx, tf] = listdlg('ListString',succStr,'PromptString',['Select PR to ' str],'SelectionMode','multiple');
if ~tf
    return;
end

succs = succs(idx);

if prop
    R = getDeps(allG, 'down', succs);
    succsIdx = ismember(allG.Nodes.Name, succs);
    succNodesIdx = any(logical(R(succsIdx,:)),1);
    succs = allG.Nodes.Name(succNodesIdx);
end

if add
    newSuccIdx = ~ismember(succs,G.Nodes.Name);
else
    newSuccIdx = ismember(succs,G.Nodes.Name);
end
newSucc = succs(newSuccIdx); % The potential new nodes to add/remove.

if isequal(str,'add')
    addNodesToView(fig,newSucc);
elseif isequal(str,'remove')
    removeNodesFromView(fig,newSucc);
end

Current_View = getCurrent('Current_View');
G = filterGraph(fig, Current_View);

renderGraph(fig, G);