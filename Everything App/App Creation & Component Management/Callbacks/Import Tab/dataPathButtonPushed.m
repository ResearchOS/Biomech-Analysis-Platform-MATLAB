function []=dataPathButtonPushed(src,event)

%% PURPOSE: OPEN A UI FOLDER PICKER TO SELECT THE FOLDER WHERE THE DATA FOR THIS PROJECT IS STORED.
% NOTE: CURRENTLY ASSUMES THAT ALL DATA IS IN SUBFOLDERS OF THIS DIRECTORY

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

% 1. Prompt for the path
dataPath=getappdata(fig,'dataPath');
path=uigetdir(dataPath,'Select the data folder for the current project');
if isequal(path,0) % 'Cancel' or 'Close' button was clicked.
    figure(fig);
    return;
end

% 2. Ensure that there is always a slash at the end of the data path.
dataPath=path;
if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end
if ~isequal(dataPath(end),slash)
    dataPath=[dataPath slash]; % Ensure that there is always a slash at the end of the data path.
end

% 3. Update the value of the code path edit field
handles.Import.dataPathField.Value=dataPath;

% 4. Run the codePathEditFieldValueChanged callback
dataPathFieldValueChanged(fig);