function []=endFrameButtonPushed(src,event)

%% PURPOSE: SET THE VARIABLES THAT DICTATES THE END FRAME OF THE MOVIE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

VariableNamesList=getappdata(fig,'VariableNamesList');

Q=uifigure;
Qhandles.varsListbox=uitree(Q,'Position',[10 10 300 400],'DeleteFcn',@(Q,event) startEndFramePopupDeleted(Q));

setappdata(Q,'handles',Qhandles);

[~,sortIdx]=sort(upper(VariableNamesList.GUINames));

makeVarNodesStartEndFramePopup(Q,sortIdx,VariableNamesList);

setappdata(Q,'idxType','endFrame');