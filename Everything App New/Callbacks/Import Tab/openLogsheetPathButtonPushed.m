function []=openLogsheetPathButtonPushed(src,event)

%% PURPOSE: OPEN THE SELECTED LOGSHEET FILE FOR THIS PROJECT

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Import.logsheetPathField.Value;

if isempty(path) || exist(path,'file')~=2
    beep;
    warning('Need to enter a valid logsheet path!');
    return;
end

openPathWithDefaultApp(path);