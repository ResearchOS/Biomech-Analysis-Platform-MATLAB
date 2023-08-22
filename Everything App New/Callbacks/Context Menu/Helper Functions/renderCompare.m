function []=renderCompare(src,fcnNames,inputVars,outputVars)

%% PURPOSE: VISUALLY SHOW THE COMPARISON BETWEEN VERSIONS IN A POPUP WINDOW.

pgui=ancestor(src,'figure','toplevel');
pguiHandles=getappdata(pgui,'handles');

%% Create all of the components

fig=uifigure('Name',['Compare Versions: ' origName],'AutoResizeChildren','off',...
    'Visible','on','SizeChangedFcn',@(renderCompareSizeChanged,event) renderCompareResize(renderCompareSizeChanged));

handles=initializeComponents_RenderCompare(fig,fcnNames);
setappdata(fig,'handles',handles);

renderCompareResize(fig);

setappdata(fig,'pguiHandles',pguiHandles);
setappdata(fig,'pgui',pgui);

%% Fill in all of the panels with the different versions.