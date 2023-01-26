function []=unassignComponentButtonPushed(src,event)

%% PURPOSE: REMOVE A COMPONENT FROM THE SELECTED PLOT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Plot.plotUITree;

selNode=uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

text=selNode.Text;

componentPath=getClassFilePath(text, 'Component', fig);
componentStruct=loadJSON(componentPath);

%% If an axes is selected, bring up a dialog box to confirm that all the children of that axes will also be deleted.
name=deText(text);
if isequal(name,'Axes')
    isAx=true;
else
    isAx=false;
end

parent=selNode.Parent;
if isAx
    sel=uiconfirm(fig,'Delete Axes? This is not reversible, and will disassociate all children components!','Confirm Delete Axes','Icon','warning');
    if ~isequal(sel,'OK')
        return;
    end    
    projectSettings=getProjectSettingsFile(fig);
    Current_Plot_Name=loadJSON(projectSettings,'Current_Plot_Name');
    parentText=Current_Plot_Name;
    class='Plot';
else
    parentText=parent.Text;
    class='Component';
end

parentPath=getClassFilePath(parentText,class,fig);
parentStruct=loadJSON(parentPath);

[componentStruct, parentStruct]=unlinkClasses(fig, componentStruct, parentStruct);

% Unlink all of the child components from the axes.
if isAx
    children=componentStruct.BackwardLinks_Component;
    for i=1:length(children)
        childPath=getClassFilePath(children{i},'Component', fig);
        childStruct=loadJSON(childPath);
        unlinkClasses(fig, childStruct, componentStruct);
    end
end

idxNum=find(ismember(parent.Children,selNode)==1);

delete(parent.Children(idxNum));

if idxNum>length(parent.Children)
    idxNum=idxNum-1;
end

if idxNum==0
    newSelNode=[];
else
    newSelNode=parent.Children(idxNum);
end

uiTree.SelectedNodes=newSelNode;

plotUITreeSelectionChanged(fig);

% projectSettingsFile=getProjectSettingsFile(fig);
% Current_Plot_Name=loadJSON(projectSettingsFile,'Current_Plot_Name');
% 
% % Get the currently selected plot struct
% fullPath=getClassFilePath(Current_Plot_Name,'Plot',fig);
% plotStruct=loadJSON(fullPath);
% 
% idx=ismember(plotStruct.Components,text);
% 
% plotStruct.Components(idx)=[];
% 
% unlinkClasses(fig, componentStruct, plotStruct);