function []=okButtonPushed(fig,event)

fig=ancestor(fig,'figure','toplevel');
handles=getappdata(fig,'handles');
patchColor=handles.patch.FaceColor;
assignin('base','splitColor',patchColor);
close(fig);

end