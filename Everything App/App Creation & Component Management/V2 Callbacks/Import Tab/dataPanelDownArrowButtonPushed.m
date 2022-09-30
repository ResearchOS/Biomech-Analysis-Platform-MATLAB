function []=dataPanelDownArrowButtonPushed(src,event)

%% PURPOSE: SCROLL THE VIEW OF THE DATA PANEL ENTRIES DOWN

fig=ancestor(src,'figure','toplevel');

dataPanelArrowCount=getappdata(fig,'dataPanelArrowCount');

setappdata(fig,'dataPanelArrowCount',dataPanelArrowCount-1);

dataPanel=findobj(fig,'Type','uipanel','Tag','SelectDataPanel');
dataSelectPanelResize(dataPanel);