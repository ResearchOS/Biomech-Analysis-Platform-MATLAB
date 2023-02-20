function []=unassignGroupButtonPushed(src,event)

%% PURPOSE: UNASSIGN PROCESSING GROUP FROM THE CURRENT GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.groupUITree;

selNode=uiTree.SelectedNodes;

if isempty(selNode)
    return;
end

name=selNode.Text;

nodeClass=selNode.NodeData.Class;

if ~isequal(nodeClass,'ProcessGroup')
    disp('Must have a processing group selected to use this button!');
    return;
end

processGroupPath=getClassFilePath(name, 'ProcessGroup');
processGroupStruct=loadJSON(processGroupPath);

selectNeighborNode(selNode);
delete(selNode);

groupUITreeSelectionChanged(fig);

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);
Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;

% Get the currently selected group struct.
fullPath=getClassFilePath_PS(Current_ProcessGroup_Name,'ProcessGroup');
groupStruct=loadJSON(fullPath);

names=groupStruct.ExecutionListNames; % Execute these functions/groups in this order.
types=groupStruct.ExecutionListTypes;

idx=ismember(names,name);

names(idx)=[];
types(idx)=[];

groupStruct.ExecutionListNames=names;
groupStruct.ExecutionListTypes=types;

unlinkClasses(processGroupStruct, groupStruct);