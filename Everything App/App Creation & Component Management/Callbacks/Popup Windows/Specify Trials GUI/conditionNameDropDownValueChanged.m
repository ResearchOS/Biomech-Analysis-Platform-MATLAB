function []=conditionNameDropDownValueChanged(src, event)

%% PURPOSE: FILL IN ALL OF THE LOGSHEET & STRUCT CRITERIA FOR THE CURRENT CONDITION WITHIN THE CURRENT SPECIFY TRIALS VERSION

value=src.Value;
fig=ancestor(src,'figure','toplevel');

logsheetHandles=getappdata(fig,'logsheetEntryHandles');
structHandles=getappdata(fig,'structEntryHandles');