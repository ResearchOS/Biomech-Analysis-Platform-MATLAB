function []=opendbFilePathButtonPushed(src,event)

%% PURPOSE: OPEN THE COMMON (PROJECT-INDEPENDENT) SETTINGS PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

dbFile = getCurrent('dbFile');
[folder] = fileparts(dbFile);

if isempty(folder) || exist(folder,'dir')~=7
    beep;
    warning('Need to enter a valid common path!');
    return;
end

if ispc==1
    winopen(folder);
    return;
end

newPath=['''' folder ''''];

system(['open ' newPath]);