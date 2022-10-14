function []=assignMultVarStatsButtonPushed(src,event)

%% PURPOSE: ASSIGN A DATA VARIABLE TO THE CURRENT REPETITION MULTI VARIABLE. THIS WILL ENSURE THAT THIS VARIABLE IS REPRESENTED ON MULTIPLE LINES OF THE STATS TABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');