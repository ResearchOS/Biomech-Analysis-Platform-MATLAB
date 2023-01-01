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

if ispc==1
    winopen(path);
    return;
end

spaceSplit=strsplit(path,' ');

newPath='';
for i=1:length(spaceSplit)
    if i>1        
        mid='\ ';
    else
        mid='';
    end
    newPath=[newPath mid spaceSplit{i}];
end

system(['open ' newPath]);