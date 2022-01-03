function []=openDataPathButtonPushed(src,event)

fig=ancestor(src,'figure','toplevel');

path=getappdata(fig,'dataPath');

if isempty(path) || exist(path,'dir')~=7
    beep;
    warning('Need to enter the data path!');
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