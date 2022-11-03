function []=editPubTableButtonPushed(src,event)

%% PURPOSE: OPEN THE WINDOW TO EDIT THE CURRENT PUBLICATION TABLE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');