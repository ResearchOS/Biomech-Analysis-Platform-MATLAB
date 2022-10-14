function []=multiRepPopupWindowDeleteFcn(src,event)

%% PURPOSE: STORE THE CHANGES MADE IN THE POPUP WINDOW BACK TO THE STATS VARIABLE IN THE PGUI
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

