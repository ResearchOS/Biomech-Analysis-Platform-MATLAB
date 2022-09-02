function []=logVarsUITreeSelectionChanged(src,logVarHeaderName)

%% PURPOSE: SHOW THE ATTRIBUTES OF THE CURRENTLY SELECTED LOGSHEET VARIABLE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

if exist('logVarHeaderName','var')~=1
    logVarHeaderName=handles.Import.logVarsUITree.SelectedNodes.Text;
    runLog=true;
else
    handles.Import.logVarsUITree.SelectedNodes=findobj(handles.Import.logVarsUITree,'Text',logVarHeaderName);
    %     logVarHeaderName=handles.Import.logVarsUITree.SelectedNodes.Text;
    runLog=false;
end
headerNameVar=genvarname(logVarHeaderName);

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct');

handles.Import.dataTypeDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).DataType;
handles.Import.trialSubjectDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject;
% handles.Import.logVarNameField.Value=NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).VarName;

if runLog
    desc='Selected a new logsheet variable in the Import tab';
    updateLog(fig,desc,logVarHeaderName);
end