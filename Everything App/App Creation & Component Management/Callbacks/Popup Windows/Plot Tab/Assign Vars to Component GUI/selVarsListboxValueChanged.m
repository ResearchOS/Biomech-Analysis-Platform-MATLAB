function []=selVarsListboxValueChanged(src)

%% PURPOSE: SWITCH THE NAME IN CODE FOR THE SELECTED VARIABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

comp=getappdata(fig,'structComp');

if isempty(handles.selVarsListbox.SelectedNodes)
    return;
end

varName=handles.selVarsListbox.SelectedNodes.Text;

idx=ismember(comp.Names,varName);

nameInCode=comp.NamesInCode{idx};

handles.varNameInCodeEditField.Value=nameInCode;

if isfield(comp,'Subvars')
    if length(comp.Subvars)<length(idx)
        handles.subvarsTextArea.Value='';
        comp.Subvars{idx}='';
        setappdata(fig,'structComp',comp);
    else
        if isempty(comp.Subvars{idx})
            comp.Subvars{idx}='';
        end
        handles.subvarsTextArea.Value=comp.Subvars{idx};
    end
else
    handles.subvarsTextArea.Value='';
    comp.Subvars{idx}='';
    setappdata(fig,'structComp',comp);
end