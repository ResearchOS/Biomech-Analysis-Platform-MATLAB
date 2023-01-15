function []=removeArgsButtonPushed(src,event)

%% PURPOSE:

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');