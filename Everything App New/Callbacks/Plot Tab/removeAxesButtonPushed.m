function []=removeAxesButtonPushed(src,event)

%% PURPOSE: REMOVE AXES FROM CURRENT PLOT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');