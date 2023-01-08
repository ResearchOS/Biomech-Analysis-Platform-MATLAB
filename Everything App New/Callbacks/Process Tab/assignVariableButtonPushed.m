function []=assignVariableButtonPushed(src,event)

%% PURPOSE: ASSIGN VARIABLE TO CURRENT PROCESSING FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');