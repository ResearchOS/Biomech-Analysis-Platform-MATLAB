function []=assignFunctionButtonPushed(src,event)

%% PURPOSE: ASSIGN PROCESSING FUNCTION TO THE CURRENT PROCESSING GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.allProcessUITree.SelectedNodes;

if isempty(selNode)
    return;
end

% fcn=selNode.Text;

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'Current_ProcessGroup_Name');

% Get the currently selected group struct.
fullPath=getClassFilePath(Current_ProcessGroup_Name,'ProcessGroup',fig);
groupStruct=loadJSON(fullPath);

% List is a Nx2, with the first column being "Process" or "ProcessGroup", 2nd
% column is the name
names=groupStruct.ExecutionListNames; % Execute these functions/groups in this order.
types=groupStruct.ExecutionListTypes;

processName=selNode.Text; % Without project-specific ID.

psid=createPSID(fig, processName, 'Process');

processName=[processName '_' psid];

names=[names; {processName}];
types=[types; {'Process'}];

groupStruct.ExecutionListNames=names;
groupStruct.ExecutionListTypes=types;

saveClass(fig,'ProcessGroup',groupStruct);

fillProcessGroupUITree(fig);