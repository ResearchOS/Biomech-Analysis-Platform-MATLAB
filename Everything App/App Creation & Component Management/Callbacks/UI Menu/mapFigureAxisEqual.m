function []=mapFigureAxisEqual(src,event)

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axis(handles.Process.mapFigure,'equal','on');