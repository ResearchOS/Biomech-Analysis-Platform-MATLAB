function []=addToQueueButtonPushed(src,event)

%% PURPOSE: ADD THE CURRENT PROCESSING FUNCTION OR GROUP TO QUEUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');