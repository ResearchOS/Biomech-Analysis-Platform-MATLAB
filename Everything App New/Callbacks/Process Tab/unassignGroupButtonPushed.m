function []=unassignGroupButtonPushed(src,event)

%% PURPOSE: UNASSIGN PROCESSING GROUP FROM THE CURRENT GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% unlinkClasses(fig, struct, currGroupStruct);