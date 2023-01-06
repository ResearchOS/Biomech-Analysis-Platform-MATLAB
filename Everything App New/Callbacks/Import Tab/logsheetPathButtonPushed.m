function []=logsheetPathButtonPushed(src,event)

%% PURPOSE: OPEN A UI FILE PICKER TO SELECT THE LOGSHEET PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

[file, shortPath]=uigetfile({'*.csv;*.xls;*.xlsx','All Excel Files (csv, xls, xlsx)'},'Select the logsheet file');

path=[shortPath file];
if file==0
    return;
end

if exist(path,'file')~=2
    disp('Specified path is not a file or does not exist');
    return;
end

handles.Import.logsheetPathField.Value=path;

logsheetPathFieldValueChanged(fig);