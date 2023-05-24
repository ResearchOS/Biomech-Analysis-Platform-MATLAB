function []=removeSpecifyTrialsButtonPushed(src,event)

%% PURPOSE: REMOVE A SPECIFY TRIALS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');