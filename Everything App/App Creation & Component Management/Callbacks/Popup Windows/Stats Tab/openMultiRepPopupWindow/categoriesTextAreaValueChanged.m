function []=categoriesTextAreaValueChanged(src,event)

%% PURPOSE: SET THE CATEGORIES FOR THE CURRENT REPETITION MULTI VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');