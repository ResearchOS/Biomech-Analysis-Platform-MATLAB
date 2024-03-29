function []=fillPlotUITree(src)

%% PURPOSE: FILL THE CURRENT PLOT UI TREE
% Plots are linked to axes (Components), and axes are linked to all other Components

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);
Current_Plot_Name=projectSettings.Current_Plot_Name;

fullPath=getClassFilePath(Current_Plot_Name,'Plot');
struct=loadJSON(fullPath);

if isfield(struct,'BackwardLinks_Component')
    axes=struct.BackwardLinks_Component;
else
    axes={};
end

uiTree=handles.Plot.plotUITree;

delete(uiTree.Children);
delete(handles.Plot.componentUITree.Children);

if isempty(axes)
    return;
end

%% Fill in the components. Axes are top level, all the other components are within the axes.
for i=1:length(axes)
    currAx=axes{i};
    newNode=uitreenode(uiTree,'Text',currAx);
    assignContextMenu(newNode,handles);

    if i==1
        uiTree.SelectedNodes=newNode;
    end

    axPath=getClassFilePath(currAx, 'Component');
    axStruct=loadJSON(axPath);
    if isfield(axStruct,'BackwardLinks_Component')
        components=axStruct.BackwardLinks_Component;
    else
        components={};
    end

    for j=1:length(components)
        newNode2=uitreenode(newNode,'Text',components{j});
        assignContextMenu(newNode2,handles);
    end
end