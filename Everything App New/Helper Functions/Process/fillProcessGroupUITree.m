function []=fillProcessGroupUITree(src)

%% PURPOSE: FILL THE CURRENT GROUP UI TREE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);
Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;
Currrent_Analysis=projectSettings.Current_Analysis;

% fullPath=getClassFilePath_PS(Current_ProcessGroup_Name, 'ProcessGroup');
fullPath=getClassFilePath_PS(Current_Analysis,'Analysis');
struct=loadJSON(fullPath);

list = struct.RunList;
% types=struct.ExecutionListTypes; % Process functions or groups
% names=struct.ExecutionListNames; % The names of each function/group

uiTree=handles.Process.groupUITree;

delete(uiTree.Children);

if isempty(types)    
    return;
end

for i=1:length(names)
    newNode=uitreenode(uiTree,'Text',names{i});
    newNode.NodeData.Class=types{i};
    assignContextMenu(newNode,handles);

    if ~isequal(types{i},'ProcessGroup')
        continue;
    end

    createProcessGroupNode(newNode,names{i},handles);    

end