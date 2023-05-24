function []=makeAxLimsSelVarNodes(src,event)

%% PURPOSE: CREATE THE SELECTED VARIABLES UI TREE NODES FOR THE AXES LIMITS GUI
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

axLims=getappdata(fig,'axLims');

dim=handles.dimDropDown.Value;

varNames=axLims.(dim).VariableNames;
subVars=axLims.(dim).SubvarNames;

varTree=handles.selVarsUITree;
delete(varTree.Children);

for i=1:length(varNames)
    a=uitreenode(varTree,'Text',varNames{i});
    if i==1
        handles.subVarEditField.Value=subVars{i};
        varTree.SelectedNodes=a;
    end
end

if isempty(varNames)
    handles.subVarEditField.Value='';
end