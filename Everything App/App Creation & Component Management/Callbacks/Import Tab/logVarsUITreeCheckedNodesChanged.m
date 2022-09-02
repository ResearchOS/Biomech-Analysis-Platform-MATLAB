function []=logVarsUITreeCheckedNodesChanged(src,logVarHeaderName)

%% PURPOSE: CHECK IF ALL METADATA IS PRESENT FOR THIS TREENODE. IF NOT, DON'T ALLOW IT TO BE CHECKED.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

if exist('logVarHeaderName','var')~=1    
    logVarHeaderName=handles.Import.logVarsUITree.SelectedNodes.Text;
    runLog=true;
%     desc='Selected '
%     updateLog(fig,desc,logVarHeaderName);
else
    handles.Import.logVarsUITree.SelectedNodes=findobj(handles.Import.logVarsUITree,'Text',logVarHeaderName);
    runLog=false;
end
headerNameVar=genvarname(logVarHeaderName);

checkedNode=findobj(handles.Import.logVarsUITree,'Text',logVarHeaderName);
if ~ismember(checkedNode,handles.Import.logVarsUITree.CheckedNodes)
    return; % Unchecked this node
end

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file

dataType=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType;
trialSubject=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject;

if runLog
    desc='Checked a logsheet variable header node in the Import tab';
    updateLog(fig,desc,logVarHeaderName);
end

if ~any([isempty(dataType) isempty(trialSubject)])
    return; % All metadata present, all good
end

if isempty(handles.Import.logVarsUITree.CheckedNodes(~ismember(handles.Import.logVarsUITree.CheckedNodes,checkedNode)))
    handles.Import.logVarsUITree.CheckedNodes=[];
else
    handles.Import.logVarsUITree.CheckedNodes=handles.Import.logVarsUITree.CheckedNodes(~ismember(handles.Import.logVarsUITree.CheckedNodes,checkedNode));
end
disp(['Logsheet variable missing metadata, checkbox cannot be checked: ' logVarHeaderName]);