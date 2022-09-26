function []=axLimsButtonPushed(src,event)

%% PURPOSE: OPEN A POPUP WINDOW TO SET THE AXIS LIMITS FOR THE CURRENT PLOT
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% CAN EITHER BE HARD-CODED, OR BASED ON VARIABLES.
% IF BASED ON VARIABLES, CAN BE BASED ON TRIAL, SUBJECT, OR PROJECT LEVEL EXTREMA SO THAT ALL PLOTS HAVE THE SAME AXES LIMITS

plotName=handles.Plot.plotFcnUITree.SelectedNodes.Text;

Plotting=getappdata(fig,'Plotting');

axHandle=Plotting.Plots.(plotName).Axes.A.Handle;

zlim(axHandle,[0 0.3]);
% axis(axHandle,'auto');
% axis(axHandle,'tight');
% xlim(axHandle,[800 1600]);
% ylim(axHandle,[-0.1 0.5]);

% axis(axHandle,'equal','off');