function []=unassignFunctionButtonPushed(src,event)

%% PURPOSE: UNASSIGN PROCESSING FUNCTION FROM PROCESSING GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.groupUITree;

selNode=uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

name=selNode.Text;

processPath=getClassFilePath(name, 'Process', fig);
processStruct=loadJSON(processPath);

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

groupUITreeSelectionChanged(fig);

projectSettingsFile=getProjectSettingsFile(fig);
Current_ProcessGroup_Name=loadJSON(projectSettingsFile,'Current_ProcessGroup_Name');

% Get the currently selected group struct.
fullPath=getClassFilePath_PS(Current_ProcessGroup_Name,'ProcessGroup',fig);
groupStruct=loadJSON(fullPath);

names=groupStruct.ExecutionListNames; % Execute these functions/groups in this order.
types=groupStruct.ExecutionListTypes;

idx=ismember(names,name);

names(idx)=[];
types(idx)=[];

groupStruct.ExecutionListNames=names;
groupStruct.ExecutionListTypes=types;

unlinkClasses(fig, processStruct, groupStruct);

% saveClass_PS(fig,'ProcessGroup',groupStruct);