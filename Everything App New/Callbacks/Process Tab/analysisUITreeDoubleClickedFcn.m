function []=analysisUITreeDoubleClickedFcn(src)

%% PURPOSE: AFTER DOUBLE CLICK, NAVIGATE TO THE SELECTED NODE'S UI TREE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if isequal(class(src),'matlab.ui.container.CheckBoxTree')
    return;
end

handles.Process.analysisUITree.SelectedNodes = src;
analysisUITreeSelectionChanged(src); % Make sure that the 

disp('We got one!');