function []=removeGroupButtonPushed(src,event)

%% PURPOSE: REMOVE A PROCESSING FUNCTION GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.allGroupsUITree;

groupNode=uiTree.SelectedNodes;

if isempty(groupNode)
    return;
end

slash=filesep;

processGroupPath=getClassFilePath(groupNode.Text,'ProcessGroup');
processGroupStruct=loadJSON(processGroupPath);

[folder,name]=fileparts(processGroupPath);

archiveFolder=[folder slash 'Archive'];
mkdir(archiveFolder);
archivePath=[archiveFolder slash name '.json'];

processGroupStruct.Archived=true;
processGroupStruct.Checked=false;
processGroupStruct.Visible=false;

writeJSON(processGroupPath,processGroupStruct);

movefile(processGroupPath,archivePath);

%% Remove the node from the UI tree
selectNeighborNode(groupNode);
delete(groupNode);

allGroupsUITreeSelectionChanged(fig);

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);
Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;

if isequal(groupNode.Text,Current_ProcessGroup_Name)
    selectGroupButtonPushed(fig);
end