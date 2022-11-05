function []=makeMultVarStatsNodes(fig,cats,allVars,assignedVars)

%% PURPOSE: CREATE THE NODES FOR THE CURRENT REPETITION MULTI VARIABLE
fig=ancestor(fig,'figure','toplevel');
handles=getappdata(fig,'handles');

for i=1:length(assignedVars)
    a=uitreenode(handles.assignedDataVarsListbox,'Text',assignedVars{i});
    if i==1
        handles.assignedDataVarsListbox.SelectedNodes=a;
    end
end

for i=1:length(allVars)
    a=uitreenode(handles.allDataVarsListbox,'Text',allVars{i});
    if i==1
        handles.allDataVarsListbox.SelectedNodes=a;
    end
end

if ~isempty(cats)
    handles.categoriesTextArea.Value=cats;
end
