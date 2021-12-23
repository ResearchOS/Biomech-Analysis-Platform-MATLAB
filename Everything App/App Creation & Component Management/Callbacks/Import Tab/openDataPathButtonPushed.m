function []=openDataPathButtonPushed(src,event)

fig=ancestor(src,'figure','toplevel');

system(['open ' getappdata(fig,'dataPath')])