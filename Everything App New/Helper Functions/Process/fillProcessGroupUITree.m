function []=fillProcessGroupUITree(src)

%% PURPOSE: FILL THE CURRENT GROUP UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% selNodeAllGroups=handles.Process.allGroupsUITree.SelectedNodes;

projectSettingsFile=getProjectSettingsFile(fig);
Current_ProcessGroup_Name=loadJSON(projectSettingsFile, 'Current_ProcessGroup_Name');

fullPath=getClassFilePath_PS(Current_ProcessGroup_Name, 'ProcessGroup', fig);
struct=loadJSON(fullPath);

types=struct.ExecutionListTypes; % Process functions or groups
names=struct.ExecutionListNames; % The names of each function/group

uiTree=handles.Process.groupUITree;

delete(uiTree.Children);

if isempty(types)    
    return;
end

for i=1:length(names)
    uitreenode(uiTree,'Text',names{i});
end