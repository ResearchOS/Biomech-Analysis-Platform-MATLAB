function []=saveDataToFile(backgroundToggle,projectStruct,subName,trialName)

%% PURPOSE: SAVE THE CURRENT DATA TO THE APPROPRIATE FILE.
% If background toggle is 1, save data off in the background. If 0, save the data in the serial thread.

if exist('trialName','var') && ~isempty(trialName) % Save trial level
    currData=projectStruct.(subName).(trialName);
    level='T';
elseif exist('subName','var') && ~isempty(subName) % Save subject level
    % Exclude trial names fieldnames
    
    level='S';
else % Save to project level
    % Exclude subject names fieldnames
    
    level='P';
end

%% Get file name to save to.
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

fig=evalin('base','gui;');

dataPath=getappdata(fig,'dataPath');

savePath=[dataPath 'MAT Data Files'];

if ismember(level,{'S','T'})
    savePath=[savePath slash subName];
end

if isequal(level,'T')
    savePath=[savePath slash trialName];
end

savePath=[savePath '.mat'];

save(savePath,'currData','-v6');