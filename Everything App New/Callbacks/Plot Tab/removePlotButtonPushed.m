function []=removePlotButtonPushed(src,event)

%% PURPOSE: REMOVE A PLOT FROM THE LIST.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');