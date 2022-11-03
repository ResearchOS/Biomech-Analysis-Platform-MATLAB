function []=removePubTableButtonPushed(src,event)

%% PURPOSE: REMOVE A PUBLICATION TABLE FROM THE LIST.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');