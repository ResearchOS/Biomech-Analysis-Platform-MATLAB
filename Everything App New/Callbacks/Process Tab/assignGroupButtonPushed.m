function []=assignGroupButtonPushed(src,event)

%% PURPOSE: ASSIGN PROCESSING GROUP TO THE CURRENT GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.allGroupsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

% Create a new project-specific process version
if (isequal(selNode.Parent,handles.Process.allGroupsUITree) && isempty(selNode.Children)) % Special case where there are no existing PS versions.
    isNew=true;
else
    isNew=false;
end

% PI node selected
if isequal(selNode.Parent,handles.Process.allGroupsUITree)
    if length(selNode.Children)==1
        selNode=selNode.Children(1);
    elseif length(selNode.Children)>1
        disp('Multiple options, please select a project-specific option!');
        expand(selNode);
        return;
    end
end

projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);
Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;

% Get the currently selected group struct.
fullPath=getClassFilePath_PS(Current_ProcessGroup_Name,'ProcessGroup');
selGroupStruct=loadJSON(fullPath);

% List is a Nx2, with the first column being "Process" or "ProcessGroup", 2nd
% column is the name
names=selGroupStruct.ExecutionListNames; % Execute these functions/groups in this order.
types=selGroupStruct.ExecutionListTypes;

groupName=selNode.Text; % Without project-specific ID.

switch isNew
    case true
        processGroupPath=getClassFilePath(groupName, 'ProcessGroup');
        piStruct=loadJSON(processGroupPath);
        processGroupStruct=createProcessGroupStruct_PS(piStruct);
    case false
        processGroupPath=getClassFilePath_PS(selNode.Text, 'ProcessGroup');
        processGroupStruct=loadJSON(processGroupPath);
end

names=[names; {processGroupStruct.Text}];
types=[types; {'ProcessGroup'}];

selGroupStruct.ExecutionListNames=names;
selGroupStruct.ExecutionListTypes=types;

linkClasses(processGroupStruct, selGroupStruct); % Also saves the structs

fillProcessGroupUITree(fig);

if isNew
    uitreenode(selNode,'Text',processGroupStruct.Text,'ContextMenu',handles.Process.psContextMenu);
end

