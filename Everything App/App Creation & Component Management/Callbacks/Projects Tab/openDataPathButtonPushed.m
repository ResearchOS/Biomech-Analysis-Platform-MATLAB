function []=openDataPathButtonPushed(src,event)

%% PURPOSE: OPEN THE DATA PATH FOLDER

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

path=handles.Projects.dataPathField.Value;

if isempty(path) || exist(path,'dir')~=7
    beep;
    warning('Need to enter a valid data path!');
    return;
end

if ispc==1
    winopen(path);
    return;
end

% spaceSplit=strsplit(path,' ');
% 
% newPath='';
% for i=1:length(spaceSplit)
%     if i>1        
%         mid='\ ';
%     else
%         mid='';
%     end
%     newPath=[newPath mid spaceSplit{i}];
% end

newPath=['''' path ''''];

system(['open ' newPath]);