function []=numHeaderRowsFieldValueChanged(src,event)

%% PURPOSE: SET & STORE THE NUMBER OF HEADER ROWS IN THIS PROJECT'S LOGSHEET.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

numHeaderRows=handles.Import.numHeaderRowsField.Value;

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

logsheetPathFieldValueChanged(fig);