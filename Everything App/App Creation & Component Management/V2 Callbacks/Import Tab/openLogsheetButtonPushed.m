function []=openLogsheetButtonPushed(src,event)

fig=ancestor(src,'figure','toplevel');

path=getappdata(fig,'logsheetPath');

if isempty(path) || exist(path,'file')~=2
    beep;
    warning('Need to enter the logsheet path!');
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