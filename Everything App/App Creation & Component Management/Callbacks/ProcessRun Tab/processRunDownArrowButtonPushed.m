function []=processRunDownArrowButtonPushed(src,event)

%% PURPOSE: INCREMENT THE COUNT FOR SCROLLING THROUGH FUNCTION NAMES ROWS, AND THEN PERFORM THE SCROLL

fig=ancestor(src,'figure','toplevel');

prevArrowCount=getappdata(fig,'processRunArrowCount');

setappdata(fig,'processRunArrowCount',prevArrowCount-1);

processRunPanel=findobj(fig,'Type','uipanel','Tag','RunFunctionsPanel');
processRunPanelResize(processRunPanel);