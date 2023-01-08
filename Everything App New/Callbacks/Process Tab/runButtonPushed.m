function []=runButtonPushed(src,event)

%% PURPOSE: RUN THE FUNCTIONS CURRENTLY SELECTED IN THE QUEUE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');