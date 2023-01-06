function []=subjectCodenameDropDownValueChanged(src,event)

%% PURPOSE: SPECIFY THE SUBJECT CODENAME

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');