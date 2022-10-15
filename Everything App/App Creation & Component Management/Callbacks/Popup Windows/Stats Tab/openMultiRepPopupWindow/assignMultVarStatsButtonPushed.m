function []=assignMultVarStatsButtonPushed(src,event)

%% PURPOSE: ASSIGN A DATA VARIABLE TO THE CURRENT REPETITION MULTI VARIABLE. THIS WILL ENSURE THAT THIS VARIABLE IS REPRESENTED ON MULTIPLE LINES OF THE STATS TABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

allDataVars=getappdata(fig,'allDataVars');
assignedVars=getappdata(fig,'assignedVars');
% cats=getappdata(fig,'cats');

selNode=handles.allDataVarsListbox.SelectedNodes;

if isempty(selNode)
    return;
end

varName=selNode.Text;

allDataVars=allDataVars(~ismember(allDataVars,varName)); % Remove the selected variable name from the all variables list.

assignedVars=[assignedVars; {varName}];

[~,sortIdx]=sort(upper(assignedVars));
assignedVars=assignedVars(sortIdx);

idx=find(ismember(assignedVars,varName));

if idx==1 && length(assignedVars)>1
    loc='before';
    nodeIdx=1;
elseif idx>1
    loc='after';
    nodeIdx=idx-1;
end

if ~(idx==1 && length(assignedVars)==1) % If the box is currently empty
    siblingNode=handles.assignedDataVarsListbox.Children(nodeIdx);
end

% Modify the nodes
delete(selNode); % Delete the selected node from the allDataVarsListbox

if ~(idx==1 && length(assignedVars)==1)
    a=uitreenode(handles.assignedDataVarsListbox,siblingNode,loc,'Text',varName);
else
    a=uitreenode(handles.assignedDataVarsListbox,'Text',varName);
end

handles.assignedDataVarsListbox.SelectedNodes=a;

% Set the data back to the figure
setappdata(fig,'allDataVars',allDataVars);
setappdata(fig,'assignedVars',assignedVars);