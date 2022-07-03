function []=openPISettingsPathButtonPushed(src,event)

%% PURPOSE: OPEN THE FOLDER CONTAINING THE PROJECT-INDEPENDENT SETTINGS FILE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

folderPath=[getappdata(fig,'everythingPath') 'Project-Independent Settings'];

if exist(folderPath,'dir')~=7
    beep;
    disp(['The project-independent settings folder does not exist! It should live in this folder: ' folderPath]);
    return;
end

if ispc==1
    winopen(folderPath);
    return;
end

spaceSplit=strsplit(folderPath,' ');

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