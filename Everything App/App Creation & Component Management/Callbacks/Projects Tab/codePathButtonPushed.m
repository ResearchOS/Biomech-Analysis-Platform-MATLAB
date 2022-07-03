function []=codePathButtonPushed(src,event)

%% PURPOSE: OPEN A UI FOLDER PICKER TO SELECT THE CODE PATH FOR THE CURRENT PROJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
% projectName=getappdata(fig,'projectName');

% 1. Prompt for the path.
codePath=getappdata(fig,'codePath');
path=uigetdir(codePath,'Select the code folder for the current project');
if isequal(path,0) % 'Cancel' or 'Close' button was clicked.
    figure(fig);
    return;
end

% 2. Ensure that there is always a slash at the end of the code path.
codePath=path;
if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end
if ~isequal(codePath(end),slash)
    codePath=[codePath slash]; % Ensure that there is always a slash at the end of the code path.
end

% 3. Update the value of the code path edit field
handles.Projects.codePathField.Value=codePath;

% 4. Run the codePathEditFieldValueChanged callback
codePathFieldValueChanged(fig);