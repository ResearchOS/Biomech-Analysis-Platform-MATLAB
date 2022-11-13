function []=relativeViewCheckboxValueChanged(src,event)

%% PURPOSE: INDICATE WHETHER THE PLOTTED MOVIE SHOULD FOLLOW A CENTER POSITION, OR KEEP THE SAME AXES LIMITS.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axesLims=getappdata(fig,'axLims');
% isMovie=getappdata(fig,'isMovie');

dim=handles.dimDropDown.Value;

axesLims.(dim).RelativeView=handles.relativeViewCheckbox.Value;

setappdata(fig,'axLims',axesLims);