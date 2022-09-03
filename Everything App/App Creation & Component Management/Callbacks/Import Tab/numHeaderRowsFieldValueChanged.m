function []=numHeaderRowsFieldValueChanged(src,numHeaderRows)

%% PURPOSE: SET & STORE THE NUMBER OF HEADER ROWS IN THIS PROJECT'S LOGSHEET.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

if exist('numHeaderRows','var')~=1
    numHeaderRows=handles.Import.numHeaderRowsField.Value;
    runLog=true;
else
    handles.Import.numHeaderRowsField.Value=numHeaderRows;
    runLog=false;
end

if isempty(numHeaderRows)
    return;
end

if numHeaderRows<0
    warning(['Number of header rows in logsheet cannot be negative']);
    return;
end

projectSettingsMATPath=getProjectSettingsMATPath(fig,projectName);

load(projectSettingsMATPath,'NonFcnSettingsStruct');

NonFcnSettingsStruct.Import.NumHeaderRows=numHeaderRows;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

if runLog
    desc='Change the number of header rows in the logsheet';
    updateLog(fig,desc,numHeaderRows);    
    logsheetPathFieldValueChanged(fig);
else    
    logsheetPath=getappdata(fig,'logsheetPath');
    logsheetPathFieldValueChanged(fig,logsheetPath);
end