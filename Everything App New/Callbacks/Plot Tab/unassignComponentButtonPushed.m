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

componentPath=getClassFilePath(text, 'Component');
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
    projectSettingsFile=getProjectSettingsFile();
    projectSettings=loadJSON(projectSettingsFile);
    Current_Plot_Name=projectSettings.Current_Plot_Name;
    parentText=Current_Plot_Name;
    parentClass='Plot';
else
    parentText=parent.Text;
    parentClass='Component';
end

parentPath=getClassFilePath(parentText,parentClass);
parentStruct=loadJSON(parentPath);

[componentStruct, parentStruct]=unlinkClasses(componentStruct, parentStruct);

% Unlink all of the child components from the axes.
if isAx && isfield(componentStruct,'BackwardLinks_Component')
    children=componentStruct.BackwardLinks_Component;
    for i=1:length(children)
        childPath=getClassFilePath(children{i},'Component');
        childStruct=loadJSON(childPath);
        unlinkClasses(childStruct, componentStruct);
    end
end

idxNum=find(ismember(parent.Children,selNode)==1);

delete(parent.Children(idxNum));

if idxNum>length(parent.Children)
    idxNum=idxNum-1;
end

if idxNum==0
    if isequal(parent,handles.Plot.plotUITree)
        newSelNode=[];
    else
        newSelNode=parent;
    end
else
    newSelNode=parent.Children(idxNum);
end

uiTree.SelectedNodes=newSelNode;

plotUITreeSelectionChanged(fig);