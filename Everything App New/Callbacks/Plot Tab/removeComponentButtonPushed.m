function []=removeComponentButtonPushed(src,event)

%% PURPOSE: REMOVE A PLOT COMPONENT FROM THE LIST

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');