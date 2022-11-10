function []=assignVarButtonPushedAxesLims(src,event)

%% PURPOSE: ASSIGN A VARIABLE TO THE CURRENT AXES LIMITS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axesLims=getappdata(fig,'axLims');