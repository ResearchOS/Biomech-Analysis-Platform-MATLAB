function []=varNameInCodeEditFieldValueChanged(src)

%% PURPOSE: STORE CHANGES TO THE VARIABLE NAME IN CODE TO THE PLOTTING VARIABLE
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

comp=getappdata(fig,'structComp');

name=handles.selVarsListbox.SelectedNodes.Text;

nameInCode=handles.varNameInCodeEditField.Value;

idx=ismember(comp.Names,name);

comp.NamesInCode{idx}=nameInCode;

setappdata(fig,'structComp',comp);