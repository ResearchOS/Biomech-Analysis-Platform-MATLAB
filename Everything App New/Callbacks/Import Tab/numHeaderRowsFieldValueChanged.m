function []=numHeaderRowsFieldValueChanged(src,event)

%% PURPOSE: SPECIFY THE NUMBER OF HEADER ROWS FOR THE CURRENT LOGSHEET

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');