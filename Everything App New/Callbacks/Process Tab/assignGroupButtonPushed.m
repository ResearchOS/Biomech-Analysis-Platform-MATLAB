function []=assignGroupButtonPushed(src,event)

%% PURPOSE: ASSIGN PROCESSING GROUP TO THE CURRENT GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.allGroupsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

fullPath=getClassFilePath(selNode);
struct=loadJSON(fullPath);

% List is a Nx2, with the first column being "Function" or "Group", 2nd
% column is the name
list=struct.ExecutionList; % Execute these functions/groups in this order.

groupName=selNode.Text;

list=[list; {'ProcessGroup', groupName}];

struct.ExecutionList=list;

projectSettingsFile=getProjectSettingsFile();
Current_ProcessGroup_Name=loadJSON(projectSettingsFile,'Current_ProcessGroup_Name');
currGroupPath=getClassFilePath(Current_ProcessGroup_Name, 'ProcessGroup');
currGroupStruct=loadJSON(currGroupPath);

linkClasses(struct, currGroupStruct);

fillProcessGroupUITree(fig);