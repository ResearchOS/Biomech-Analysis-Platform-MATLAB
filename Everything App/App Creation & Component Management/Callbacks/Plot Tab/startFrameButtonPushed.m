function []=startFrameButtonPushed(src,event)

%% PURPOSE: SET THE VARIABLE TO DICTATE THE START FRAME OF THE MOVIE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

VariableNamesList=getappdata(fig,'VariableNamesList');

Q=uifigure;
Qhandles.varsListbox=uitree(Q,'Position',[10 10 300 400],'DeleteFcn',@(Q,event) startEndFramePopupDeleted(Q));

setappdata(Q,'handles',Qhandles);

[~,sortIdx]=sort(upper(VariableNamesList.GUINames));

makeVarNodesStartEndFramePopup(Q,sortIdx,VariableNamesList);

setappdata(Q,'idxType','startFrame');