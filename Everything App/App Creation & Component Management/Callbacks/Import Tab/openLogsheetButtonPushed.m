function []=openLogsheetButtonPushed(src,event)

fig=ancestor(src,'figure','toplevel');

path=getappdata(fig,'logsheetPath');

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

system(['open ' getappdata(fig,'logsheetPath')])