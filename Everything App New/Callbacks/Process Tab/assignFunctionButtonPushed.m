function []=assignFunctionButtonPushed(src,event)

%% PURPOSE: ASSIGN PROCESSING FUNCTION TO THE CURRENT PROCESSING GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.allProcessUITree.SelectedNodes;

if isempty(selNode)
    return;
end

% Create a new project-specific process version
if (isequal(selNode.Parent,handles.Process.allProcessUITree) && isempty(selNode.Children)) % Special case where there are no existing PS versions.
    isNew=true;
else
    isNew=false;
end

% PI node selected
if isequal(selNode.Parent,handles.Process.allProcessUITree)
    if length(selNode.Children)==1
        selNode=selNode.Children(1);
    else
        disp('Multiple options, please select a project-specific option!');
        expand(selNode);
        return;
    end
end

projectSettingsFile=getProjectSettingsFile();
Current_ProcessGroup_Name=loadJSON(projectSettingsFile,'Current_ProcessGroup_Name');

% Get the currently selected group struct.
fullPath=getClassFilePath_PS(Current_ProcessGroup_Name,'ProcessGroup');
groupStruct=loadJSON(fullPath);

% List is a Nx2, with the first column being "Process" or "ProcessGroup", 2nd
% column is the name
names=groupStruct.ExecutionListNames; % Execute these functions/groups in this order.
types=groupStruct.ExecutionListTypes;

processName=selNode.Text; % Without project-specific ID.

switch isNew
    case true
        processPath=getClassFilePath(processName, 'Process');
        piStruct=loadJSON(processPath);
        processStruct=createProcessStruct_PS(piStruct);
    case false
        processPath=getClassFilePath_PS(selNode.Text, 'Process');
        processStruct=loadJSON(processPath);
end

names=[names; {processStruct.Text}];
types=[types; {'Process'}];

groupStruct.ExecutionListNames=names;
groupStruct.ExecutionListTypes=types;

linkClasses(processStruct, groupStruct); % Also saves the structs

newNode=uitreenode(handles.Process.groupUITree,'Text',processStruct.Text);
newNode.ContextMenu=handles.Process.psContextMenu;

if isNew
    uitreenode(selNode,'Text',processStruct.Text,'ContextMenu',handles.Process.psContextMenu);
end