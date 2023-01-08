function []=removeFromQueueButtonPushed(src,event)

%% PURPOSE: REMOVE THE CURRENT PROCESSING FUNCTION OR GROUP FROM THE QUEUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');