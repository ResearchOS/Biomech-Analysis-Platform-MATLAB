function []=subvarsStatsTextAreaValueChanged(src,event)

%% PURPOSE: CHANGE THE SUBVARIABLES TAKEN FROM THAT VARIABLE.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

subVar=handles.subvarsTextArea.Value{1};

% plotName=getappdata(fig,'plotName');
% compName=getappdata(fig,'compName');
% letter=getappdata(fig,'letter');
currNode=getappdata(fig,'currNode');

currVarName=handles.selVarsListbox.SelectedNodes.Text;

idx=ismember(currNode.GUINames,currVarName);

currNode.Subvars{idx,1}=strtrim(subVar);

setappdata(fig,'currNode',currNode);