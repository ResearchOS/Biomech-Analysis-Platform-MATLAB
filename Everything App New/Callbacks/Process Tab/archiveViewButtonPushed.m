function []=archiveViewButtonPushed(src,event)

%% PURPOSE: ARCHIVE (DELETE?) THE CURRENT VIEW. CANNOT DELETE THE ALL VIEW

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');