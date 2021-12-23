function []=openCodePathButtonPushed(src,event)

fig=ancestor(src,'figure','toplevel');

system(['open ' getappdata(fig,'codePath')])