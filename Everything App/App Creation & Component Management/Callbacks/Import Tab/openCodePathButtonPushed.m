function []=openCodePathButtonPushed(src,event)

%% PURPOSE: OPEN THE DIRECTORY CONTAINING THE PROJECT'S CODE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Import.codePathField.Value;

if isempty(path) || exist(path,'dir')~=7
    beep;
    warning('Need to enter a valid code path!');
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