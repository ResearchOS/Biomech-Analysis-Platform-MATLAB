function []=collapseAllContextMenuClicked(src,event)

%% PURPOSE: COLLAPSE ALL VARIABLES IN THE VARSLISTBOX
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

collapse(handles.Process.varsListbox);