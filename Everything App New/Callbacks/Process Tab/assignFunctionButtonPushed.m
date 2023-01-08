function []=assignFunctionButtonPushed(src,event)

%% PURPOSE: ASSIGN PROCESSING FUNCTION TO THE CURRENT PROCESSING GROUP

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.allFunctionsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

currGroup=

fullPath=getClassFilePath(selNode.Text,'ProcessGroup');
struct=loadJSON(fullPath);

% List is a Nx2, with the first column being "Process" or "ProcessGroup", 2nd
% column is the name
list=struct.ExecutionList; % Execute these functions/groups in this order.

processName=selNode.Text;

list=[list; {'Process', processName}];

struct.ExecutionList=list;

saveClass(fig,'ProcessGroup',struct);

fillProcessGroupUITree(fig);