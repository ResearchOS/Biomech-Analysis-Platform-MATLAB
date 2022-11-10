function []=unassignVarButtonPushedAxesLims(src,event)

%% PURPOSE: REMOVE A VARIABLE FROM THE CURRENT AXES LIMS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axesLims=getappdata(fig,'axLims');