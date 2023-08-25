function []=openLogsheetPathButtonPushed(src,event)

%% PURPOSE: OPEN THE SELECTED LOGSHEET FILE FOR THIS PROJECT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% path=handles.Import.logsheetPathField.Value;
logsheet = getCurrent('Current_Logsheet');
computerID = getCurrent('Computer_ID');
path = logsheet.Logsheet_Path.(computerID);

if isempty(path) || exist(path,'file')~=2
    beep;
    warning('Need to enter a valid logsheet path!');
    return;
end

openPathWithDefaultApp(path);