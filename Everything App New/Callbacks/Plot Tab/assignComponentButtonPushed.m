function []=assignComponentButtonPushed(src,event)

%% PURPOSE: ASSIGN A COMPONENT TO A PLOT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Plot.allComponentsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

% Create a new project-specific process version
if isequal(selNode.Parent,handles.Plot.allComponentsUITree)
    isNew=true;
else
    isNew=false;
end

projectSettingsFile=getProjectSettingsFile(fig);
Current_Plot_Name=loadJSON(projectSettingsFile,'Current_Plot_Name');

% Get the currently selected plot struct
fullPath=getClassFilePath(Current_Plot_Name,'Plot', fig);
plotStruct=loadJSON(fullPath);

componentName=selNode.Text; % Without project-specific ID.

switch isNew
    case true
        componentPath=getClassFilePath(componentName, 'Component', fig);
        piStruct=loadJSON(componentPath);
        componentStruct=createComponentStruct_PS(fig, piStruct);
    case false
        componentPath=getClassFilePath(componentName, 'Component', fig);
        componentStruct=loadJSON(componentPath);
end

plotStruct.Components=[plotStruct.Components; {componentStruct.Text}];

linkClasses(fig, componentStruct, plotStruct); % Also saves the structs

newNode=uitreenode(handles.Plot.plotUITree,'Text',componentStruct.Text);
newNode.ContextMenu=handles.Process.psContextMenu;

handles.Plot.plotUITree.SelectedNodes=newNode;
plotUITreeSelectionChanged(fig);

if isNew
    uitreenode(selNode,'Text',componentStruct.Text,'ContextMenu',handles.Process.psContextMenu);
end