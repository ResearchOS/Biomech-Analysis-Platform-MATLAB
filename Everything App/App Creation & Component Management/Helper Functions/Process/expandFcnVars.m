function []=expandFcnVars(src,event)

%% PURPOSE: EXPAND THE INPUT & OUTPUT VARIABLE NODES
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selFcn=handles.Process.fcnArgsUITree.SelectedNodes;

if ~isequal(selFcn.Parent,handles.Process.fcnArgsUITree) % Ensure that this is a function, not the variables or Input/Output label.
    return;
end

expand(selFcn);

for i=1:length(selFcn.Children) % Expand inputs & outputs
    expand(selFcn.Children(i));
end