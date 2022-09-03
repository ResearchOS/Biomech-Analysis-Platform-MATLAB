function []=subjIDColHeaderFieldValueChanged(src,subjIDColHeaderName)

%% PURPOSE: SET & STORE THE SUBJECT ID COLUMN HEADER IN THE LOGSHEET

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

if exist('subjIDColHeaderName','var')~=1
    subjIDColHeaderName=handles.Import.subjIDColHeaderField.Value;
    runLog=true;
else
    handles.Import.subjIDColHeaderField.Value=subjIDColHeaderName;
    runLog=false;
end

if isempty(subjIDColHeaderName)
    return;
end

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct');

NonFcnSettingsStruct.Import.SubjectIDColHeader=subjIDColHeaderName;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

if runLog
    desc='Change the subject codename column header in the logsheet';
    updateLog(fig,desc,subjIDColHeaderName);       
end

logsheetPath=getappdata(fig,'logsheetPath');
logsheetPathFieldValueChanged(fig,logsheetPath);