function []=saveAsNewGroupButtonPushed(src,event)

%% PURPOSE: SAVE THE CHECKED PROCESS FUNCTIONS AS A NEW GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

uiTree=handles.Process.groupUITree;

allGroupsUITree=handles.Process.allGroupsUITree;

selNodes=uiTree.CheckedNodes;

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);
Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;
defaultName='';
allNodesTexts={};

if isempty(selNodes)
    selNodes=uiTree.Children;
    allNodes=allGroupsUITree.Children;
    allNodesTexts={allNodes.Text};
    defaultName=Current_ProcessGroup_Name;    
end

%% Ask whether this is an entirely new group, or a different version of the same group.
sel=uiconfirm(fig,'New version or new group entirely?','Group Type','Options',{'New Version','New Group','Cancel'},'DefaultOption',2,'CancelOption',3);

if isequal(sel,'Cancel')
    return;
end

if isequal(sel,'New Version')    
    [name,id]=deText(defaultName);
    piText=[name '_' id];
    piPath=getClassFilePath(piText,'ProcessGroup');
    piStruct=loadJSON(piPath);
    psStruct=createProcessGroupStruct_PS(piStruct);

    parentNodeIdx=ismember(allNodesTexts,piStruct.Text);
    psNode=uitreenode(allNodes(parentNodeIdx),'Text',psStruct.Text);

elseif isequal(sel,'New Group')
    newName=promptName('New Group Name');
    piStruct=createProcessGroupStruct(newName);
    psStruct=createProcessGroupStruct_PS(piStruct);

    piNode=uitreenode(allGroupsUITree,'Text',piStruct.Text); 
    assignContextMenu(piNode,handles);
    psNode=uitreenode(piNode,'Text',psStruct.Text);

end

assignContextMenu(psNode,handles);

%% Add the selected functions/groups to the new group.
for i=1:length(selNodes)

    currPath=getClassFilePath(selNodes(i).Text,selNodes(i).NodeData.Class);
    currStruct=loadJSON(currPath);
    linkClasses(currStruct,psStruct);

    psStruct.ExecutionListNames=[psStruct.ExecutionListNames; {selNodes(i).Text}];
    psStruct.ExecutionListTypes=[psStruct.ExecutionListTypes; {selNodes(i).NodeData.Class}];    

end

allGroupsUITree.SelectedNodes=psNode;
selectGroupButtonPushed(fig);