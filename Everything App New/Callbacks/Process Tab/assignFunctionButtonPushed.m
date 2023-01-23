function []=assignFunctionButtonPushed(src,event)

%% PURPOSE: ASSIGN PROCESSING FUNCTION TO THE CURRENT PROCESSING GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.allProcessUITree.SelectedNodes;

if isempty(selNode)
    return;
end

% Create a new project-specific process version
if isequal(selNode.Parent,handles.Process.allProcessUITree)
    isNew=true;
else
    isNew=false;
end

projectSettingsFile=getProjectSettingsFile(fig);
Current_ProcessGroup_Name=loadJSON(projectSettingsFile,'Current_ProcessGroup_Name');

% Get the currently selected group struct.
fullPath=getClassFilePath_PS(Current_ProcessGroup_Name,'ProcessGroup',fig);
groupStruct=loadJSON(fullPath);

% List is a Nx2, with the first column being "Process" or "ProcessGroup", 2nd
% column is the name
names=groupStruct.ExecutionListNames; % Execute these functions/groups in this order.
types=groupStruct.ExecutionListTypes;

processName=selNode.Text; % Without project-specific ID.

switch isNew
    case true
        processPath=getClassFilePath(processName, 'Process', fig);
        piStruct=loadJSON(processPath);
        processStruct=createProcessStruct_PS(fig,piStruct);
    case false
        processPath=getClassFilePath_PS(selNode.Text, 'Process', fig);
        processStruct=loadJSON(processPath);
end

names=[names; {processStruct.Text}];
types=[types; {'Process'}];

groupStruct.ExecutionListNames=names;
groupStruct.ExecutionListTypes=types;

linkClasses(fig, processStruct, groupStruct); % Also saves the structs

% saveClass_PS(fig,'ProcessGroup',groupStruct);
% saveClass_PS(fig,'Process',processStruct);

newNode=uitreenode(handles.Process.groupUITree,'Text',processStruct.Text);
newNode.ContextMenu=handles.Process.psContextMenu;

if isNew
    uitreenode(selNode,'Text',processStruct.Text,'ContextMenu',handles.Process.psContextMenu);
end