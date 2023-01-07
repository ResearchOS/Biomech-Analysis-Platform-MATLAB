function []=uncheckAllButtonPushed(src,event)

%% PURPOSE: UNCHECK ALL THE VARIABLES

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

handles.Import.headersUITree.CheckedNodes=[];