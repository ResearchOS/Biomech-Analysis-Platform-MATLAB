function []=copyText(src,event)

%% PURPOSE: COPY THE TEXT OF A NODE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

text=selNode.Text;

uiTree=getUITreeFromNode(selNode);
class=getClassFromUITree(uiTree);

clipboard('copy',['Class: ' class ' Text: ' text]);