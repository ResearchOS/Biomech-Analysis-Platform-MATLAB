function []=trialSubjectDropDownValueChanged(src,headerName,trialSubject)

%% PURPOSE:

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

if exist('trialSubject','var')~=1
    trialSubject=handles.Import.trialSubjectDropDown.Value;
    headerName=handles.Import.logVarsUITree.SelectedNodes.Text;
    runLog=true;
else
    handles.Import.trialSubjectDropDown.Value=trialSubject;   
    handles.Import.logVarsUITree.SelectedNodes=findobj(handles.Import.logVarsUITree,'Text',headerName);
    runLog=false;
end

headerNameVar=genvarname(headerName);

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file

NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject=trialSubject;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

if runLog
    desc=['Changed the level of variable ' headerName ' to read in from the logsheet'];
    updateLog(fig,desc,headerName,trialSubject);
end