function []=unassignComponentButtonPushed(src,event)

%% PURPOSE: REMOVE A COMPONENT FROM THE SELECTED PLOT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Plot.plotUITree;

selNode=uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

name=selNode.Text;

componentPath=getClassFilePath(name, 'Component', fig);
componentStruct=loadJSON(componentPath);

idxNum=find(ismember(uiTree.Children,selNode)==1);

delete(uiTree.Children(idxNum));

if idxNum>length(uiTree.Children)
    idxNum=idxNum-1;
end

if idxNum==0
    uiTree.SelectedNodes=[];
else
    uiTree.SelectedNodes=uiTree.Children(idxNum);
end

plotUITreeSelectionChanged(fig);

projectSettingsFile=getProjectSettingsFile(fig);
Current_Plot_Name=loadJSON(projectSettingsFile,'Current_Plot_Name');

% Get the currently selected plot struct
fullPath=getClassFilePath(Current_Plot_Name,'Plot',fig);
plotStruct=loadJSON(fullPath);

idx=ismember(plotStruct.Components,name);

plotStruct.Components(idx)=[];

unlinkClasses(fig, componentStruct, plotStruct);