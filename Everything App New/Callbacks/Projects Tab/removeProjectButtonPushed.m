function []=removeProjectButtonPushed(src)

%% PURPOSE: CHANGE A PROJECT'S VISIBILITY TO BE REMOVED FROM THE LIST.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Projects.allProjectsUITree;

projectNode=uiTree.SelectedNodes;

if isempty(projectNode)
    return;
end

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_Project_Name');

if isequal(Current_Project_Name,projectNode.Text)
    disp('Cannot remove the current project! Select another project to remove this one.');
    return;
end

fullPath=getClassFilePath(projectNode, 'Project');
struct=loadJSON(fullPath);

struct.Checked=false;

struct.Visible=false;

saveClass(fig,'Project',struct);

idxNum=find(ismember(projectNode,uiTree.Children)==1);

delete(projectNode);

if idxNum>length(uiTree.Children)
    idxNum=idxNum-1;
end

if idxNum==0
    uiTree.SelectedNodes=[];
else
    uiTree.SelectedNodes=uiTree.Children(idxNum);
end

allProjectsUITreeSelectionChanged(fig);