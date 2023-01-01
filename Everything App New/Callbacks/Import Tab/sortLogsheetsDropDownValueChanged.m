function []=sortLogsheetsDropDownValueChanged(src,event)

%% PURPOSE: SORT THE LOGSHEETS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

