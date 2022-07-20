function []=logVarsUITreeCheckedNodesChanged(src,event)

%% PURPOSE: CHECK IF ALL METADATA IS PRESENT FOR THIS TREENODE. IF NOT, DON'T ALLOW IT TO BE CHECKED.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

headerName=handles.Import.logVarsUITree.SelectedNodes.Text;
headerNameVar=genvarname(headerName);

checkedNode=findobj(handles.Import.logVarsUITree,'Text',headerName);
if ~ismember(checkedNode,handles.Import.logVarsUITree.CheckedNodes)
    return; % Unchecked this node
end

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file

dataType=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType;
trialSubject=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject;

if ~any([isempty(dataType) isempty(trialSubject)])
    return; % All metadata present, all good
end

handles.Import.logVarsUITree.CheckedNodes=handles.Import.logVarsUITree.CheckedNodes(~ismember(handles.Import.logVarsUITree.CheckedNodes,checkedNode));
disp(['Logsheet variable missing metadata, checkbox cannot be checked: ' headerName]);