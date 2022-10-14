function []=unassignMultVarStatsButtonPushed(src,event)

%% PURPOSE: REMOVE A DATA VARIABLE FROM THE REPETITION MULT VARIABLE. THIS WILL RESULT IN ONE NUMBER PER TRIAL FOR THAT DATA VARIABLE.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');