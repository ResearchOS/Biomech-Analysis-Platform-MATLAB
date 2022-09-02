function []=trialSubjectDropDownValueChanged(src,trialSubject)

%% PURPOSE:

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

headerName=handles.Import.logVarsUITree.SelectedNodes.Text;
headerNameVar=genvarname(headerName);

if exist('trialSubject','var')~=1
    trialSubject=handles.Import.trialSubjectDropDown.Value;
    runLog=true;
else
    handles.Import.trialSubjectDropDown.Value=trialSubject;
    runLog=false;
end

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file

NonFcnSettingsStruct.Import.LogsheetVars.(headerNameVar).TrialSubject=trialSubject;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

if runLog
    desc=['Changed the level of variable ' headerName ' to read in from the logsheet'];
    updateLog(fig,desc,trialSubject);
end