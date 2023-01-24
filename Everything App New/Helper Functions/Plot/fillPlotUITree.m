function []=fillPlotUITree(src)

%% PURPOSE: FILL THE CURRENT PLOT UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsFile=getProjectSettingsFile(fig);
Current_Plot_Name=loadJSON(projectSettingsFile,'Current_Plot_Name');

fullPath=getClassFilePath(Current_Plot_Name,'Plot', fig);
struct=loadJSON(fullPath);

components=struct.Components;

uiTree=handles.Plot.plotUITree;

delete(uiTree.Children);

if isempty(components)
    return;
end

for i=1:length(components)
    newNode=uitreenode(uiTree,'Text',components{i});
    newNode.ContextMenu=handles.Process.psContextMenu;
end