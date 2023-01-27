function []=assignComponentButtonPushed(src,event)

%% PURPOSE: ASSIGN A COMPONENT TO A PLOT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Plot.allComponentsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

selCompNode=handles.Plot.plotUITree.SelectedNodes;

if isempty(selCompNode) % Typically this would be an immediate end of program, but in this case I might assume that I should create an axes component and add the component to that.
    projectSettings=getProjectSettingsFile(fig);
    Current_Plot_Name=loadJSON(projectSettings,'Current_Plot_Name');
    plotPath=getClassFilePath(Current_Plot_Name,'Plot', fig);
    plotStruct=loadJSON(plotPath);
    if isfield(plotStruct,'BackwardLinks_Component') && ~isempty(plotStruct.BackwardLinks_Component)
        return; % Things exist, but nothing is selected
    else % Nothing exists. Create an axes component.
        text='Axes_000000';
        fullPath=getClassFilePath(text,'Component', fig);
        if exist(fullPath,'file')~=2 % PI axes don't exist
            createComponentStruct(fig, 'Axes', '000000');
            assert(isempty(handles.Plot.plotUITree.Children));
            newAxes=uitreenode(handles.Plot.allComponentsUITree,'Text','Axes_000000');
            handles.Plot.allComponentsUITree.SelectedNodes=newAxes;
            assignComponentButtonPushed(fig);
            selCompNode=handles.Plot.plotUITree.Children(1);
        end
    end
end

% Create new component or not?
if isequal(selNode.Parent,handles.Plot.allComponentsUITree)
    isNew=true; % Selected PI, to create a new PS version.
else
    isNew=false; % Selected project-specific component version
end

[name]=deText(selNode.Text);

if isequal(name,'Axes') % Adding a new axes to the plot.
    isAx=true;
    projectSettingsFile=getProjectSettingsFile(fig);
    Current_Plot_Name=loadJSON(projectSettingsFile,'Current_Plot_Name');

    % Get the currently selected plot struct
    fullPath=getClassFilePath(Current_Plot_Name,'Plot', fig);
    plotStruct=loadJSON(fullPath);
    axNode=selCompNode;

else % Adding a component that's not an axes, need to find the current parent axes.
    % IF NO AXES SETTINGS OBJECT EXISTS, NEED TO INITIALIZE IT.
    isAx=false;
    if isequal(selCompNode.Parent,handles.Plot.plotUITree) % Axes node is selected.
        axNode=selCompNode;
        currAxes=selCompNode.Text;
    else % Component node is selected.
        axNode=selCompNode.Parent;
        currAxes=axNode.Text;
    end    

    fullPath=getClassFilePath(currAxes, 'Component', fig);
    axStruct=loadJSON(fullPath);
end

componentName=selNode.Text; % If isNew is true, this should be PI. If isNew is false, should be PS.
componentPath=getClassFilePath(componentName, 'Component', fig);

switch isNew
    case true
        piStruct=loadJSON(componentPath);
        componentStruct=createComponentStruct_PS(fig, piStruct);
    case false
        componentStruct=loadJSON(componentPath);
end

if isAx
    linkClasses(fig, componentStruct, plotStruct);
    parent=handles.Plot.plotUITree;
else
    linkClasses(fig, componentStruct, axStruct);
    parent=axNode;
end

newNode=uitreenode(parent,'Text',componentStruct.Text);
newNode.ContextMenu=handles.Process.psContextMenu;

handles.Plot.plotUITree.SelectedNodes=newNode;
plotUITreeSelectionChanged(fig);

if isNew
    uitreenode(selNode,'Text',componentStruct.Text,'ContextMenu',handles.Process.psContextMenu);
end