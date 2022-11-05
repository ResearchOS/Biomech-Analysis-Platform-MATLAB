function []=subvarsTextAreaValueChanged(src,event)

%% PURPOSE: CHANGE THE SUBVARIABLES TAKEN FROM THAT VARIABLE.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

subVar=handles.subvarsTextArea.Value{1};

% plotName=getappdata(fig,'plotName');
% compName=getappdata(fig,'compName');
% letter=getappdata(fig,'letter');
structComp=getappdata(fig,'structComp');

currVarName=handles.selVarsListbox.SelectedNodes.Text;

idx=ismember(structComp.Names,currVarName);

structComp.Subvars{idx}=strtrim(subVar);

setappdata(fig,'structComp',structComp);