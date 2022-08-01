function []=windowButtonDownFcn(src,event)

%% PURPOSE: RECORD WHEN THE MOUSE BUTTON IS CLICKED (DOWN). ONLY ACTIVATES IF THE CLICK WAS ON THE UIAXES OBJECT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

xlims=handles.Process.mapFigure.XLim;
ylims=handles.Process.mapFigure.YLim;

currPoint=handles.Process.mapFigure.CurrentPoint;

% assert(isequal(currPoint(1,:),[currPoint(2,1:2) -1*currPoint(2,3)]));

currPoint=currPoint(1,1:2);

if currPoint(1)<xlims(1) || currPoint(1)>xlims(2) || currPoint(2)<ylims(1) || currPoint(2)>ylims(2)
    return; % Clicked outside of the axes bounds
end

setappdata(fig,'currentPointDown',currPoint);