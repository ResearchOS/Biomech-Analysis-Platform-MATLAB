function []=selVarsListboxValueChanged(src)

%% PURPOSE: SWITCH THE NAME IN CODE FOR THE SELECTED VARIABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

currNode=getappdata(fig,'currNode');

varName=handles.selVarsListbox.SelectedNodes.Text;

idx=ismember(currNode.GUINames,varName);

nameInCode=currNode.NamesInCode{idx};

handles.varNameInCodeEditField.Value=nameInCode;

if isfield(currNode,'Subvars')
    if length(currNode.Subvars)<length(idx)
        handles.subvarsTextArea.Value='';
        currNode.Subvars{idx,1}='';
        setappdata(fig,'currNode',currNode);
    else
        if isempty(currNode.Subvars{idx})
            currNode.Subvars{idx,1}='';
        end
        handles.subvarsTextArea.Value=currNode.Subvars{idx};
    end
else
    handles.subvarsTextArea.Value='';
    currNode.Subvars{idx,1}='';
    setappdata(fig,'currNode',currNode);
end