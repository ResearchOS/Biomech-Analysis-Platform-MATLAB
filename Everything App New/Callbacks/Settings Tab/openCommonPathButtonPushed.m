function []=openCommonPathButtonPushed(src,event)

%% PURPOSE: OPEN THE COMMON (PROJECT-INDEPENDENT) SETTINGS PATH

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

rootSettingsFile=getRootSettingsFile();
load(rootSettingsFile,'commonPath');

if isempty(commonPath) || exist(commonPath,'dir')~=7
    beep;
    warning('Need to enter a valid common path!');
    return;
end

if ispc==1
    winopen(commonPath);
    return;
end

newPath=['''' commonPath ''''];

system(['open ' newPath]);