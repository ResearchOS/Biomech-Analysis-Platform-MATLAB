function []=unassignMultVarStatsButtonPushed(src,event)

%% PURPOSE: REMOVE A DATA VARIABLE FROM THE REPETITION MULT VARIABLE. THIS WILL RESULT IN ONE NUMBER PER TRIAL FOR THAT DATA VARIABLE.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

allDataVars=getappdata(fig,'allDataVars');
assignedVars=getappdata(fig,'assignedVars');

selNode=handles.assignedDataVarsListbox.SelectedNodes;

if isempty(selNode)
    return;
end

varName=selNode.Text;

assignedVars=assignedVars(~ismember(assignedVars,varName)); % Remove the selected variable name from the assigned variables list

allDataVars=[allDataVars; {varName}];

[~,sortIdx]=sort(upper(allDataVars));
allDataVars=allDataVars(sortIdx);

idx=find(ismember(allDataVars,varName));

if idx==1 && length(allDataVars)>1
    loc='before';
    nodeIdx=1;
elseif idx>1
    loc='after';
    nodeIdx=idx-1;
end

if ~(idx==1 && length(allDataVars)==1) % If the box is currently empty
    siblingNode=handles.allDataVarsListbox.Children(nodeIdx);
end

% Modify the nodes
delete(selNode); % Delete the selected node from the allDataVarsListbox

if ~(idx==1 && length(allDataVars)==1)
    a=uitreenode(handles.allDataVarsListbox,siblingNode,loc,'Text',varName);
else
    a=uitreenode(handles.allDataVarsListbox,'Text',varName);
end

handles.allDataVarsListbox.SelectedNodes=a;

% Set the data back to the figure
setappdata(fig,'allDataVars',allDataVars);
setappdata(fig,'assignedVars',assignedVars);