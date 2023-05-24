function []=unassignVarButtonPushedAxesLims(src,event)

%% PURPOSE: REMOVE A VARIABLE FROM THE CURRENT AXES LIMS
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axLims=getappdata(fig,'axLims');

dim=handles.dimDropDown.Value;

selNode=handles.selVarsUITree.SelectedNodes;

if isempty(selNode)
    return;
end

idx=ismember(handles.selVarsUITree.Children,selNode);

axLims.(dim).VariableNames(idx)=[];
axLims.(dim).SubvarNames(idx)=[];

setappdata(fig,'axLims',axLims);

makeAxLimsSelVarNodes(fig);