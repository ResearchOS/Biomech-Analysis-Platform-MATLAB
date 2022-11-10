function []=axesLimDeleteFcn(src,pguiFig)

%% PURPOSE: STORE THE SETTINGS BACK TO THE PGUI
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axLims=getappdata(fig,'axLims');
