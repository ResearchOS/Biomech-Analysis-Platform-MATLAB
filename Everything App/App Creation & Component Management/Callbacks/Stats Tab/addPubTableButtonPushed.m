function []=addPubTableButtonPushed(src,event)

%% PURPOSE: CREATE A NEW TABLE FOR PUBLICATION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');