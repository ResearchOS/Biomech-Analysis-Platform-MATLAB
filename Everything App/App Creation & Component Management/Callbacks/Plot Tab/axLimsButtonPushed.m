function []=axLimsButtonPushed(src,event)

%% PURPOSE: OPEN A POPUP WINDOW TO SET THE AXIS LIMITS FOR THE CURRENT PLOT
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% CAN EITHER BE HARD-CODED, OR BASED ON VARIABLES.
% IF BASED ON VARIABLES, CAN BE BASED ON TRIAL, SUBJECT, OR PROJECT LEVEL EXTREMA SO THAT ALL PLOTS HAVE THE SAME AXES LIMITS