function []=unassignVariableButtonPushed(src,event)

%% PURPOSE: UNASSIGN VARIABLE FROM CURRENT PROCESSING FUNCTION

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

unlinkClasses(fig, varStruct, processStruct);