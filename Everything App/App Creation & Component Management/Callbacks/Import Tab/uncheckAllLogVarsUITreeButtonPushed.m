function []=uncheckAllLogVarsUITreeButtonPushed(src,event)

%% PURPOSE: Uncheck all column headers in log var UI tree

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

handles.Import.logVarsUITree.CheckedNodes=[];