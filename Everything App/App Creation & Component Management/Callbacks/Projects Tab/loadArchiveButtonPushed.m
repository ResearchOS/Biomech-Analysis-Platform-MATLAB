function []=loadArchiveButtonPushed(src)

%% PURPOSE: LOAD A PREVIOUSLY CREATED ARCHIVE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');