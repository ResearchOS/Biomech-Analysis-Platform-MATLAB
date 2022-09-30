function []=uncheckAllLogVarsUITreeButtonPushed(src,event)

%% PURPOSE: Uncheck all column headers in log var UI tree

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

handles.Import.logVarsUITree.CheckedNodes=[];

if ~getappdata(fig,'isRunLog')
    desc='Uncheck all variables in Import tab';
    updateLog(fig,desc);
end