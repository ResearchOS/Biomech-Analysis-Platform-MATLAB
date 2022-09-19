function []=selVarsListboxValueChanged(src)

%% PURPOSE: SWITCH THE NAME IN CODE FOR THE SELECTED VARIABLE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

comp=getappdata(fig,'structComp');

varName=handles.selVarsListbox.SelectedNodes.Text;

idx=ismember(comp.Names,varName);

nameInCode=comp.NamesInCode{idx};

handles.varNameInCodeEditField.Value=nameInCode;