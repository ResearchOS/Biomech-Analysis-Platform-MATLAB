function []=logsheetPathButtonPushed(src,event)

%% PURPOSE: OPEN A UI FILE PICKER TO SELECT THE LOGSHEET FILE FOR THE CURRENT PROJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

% 1. Prompt for the logsheet path
logsheetPath=getappdata(fig,'logsheetPath');
codePath=handles.Import.codePathField.Value;
[file,path]=uigetfile({'*.xlsx';'*.xls'},'Select the logsheet file',codePath);
if isequal(file,0) && isequal(path,0) % 'Cancel' or 'Close' button was clicked
    figure(fig);
    return;
end

% 2. Update the value of the logsheet path edit field
logsheetPath=[path file];
handles.Import.logsheetPathField.Value=logsheetPath;

% 3. Run the logsheetPathEditFieldValueChanged callback
logsheetPathFieldValueChanged(fig);