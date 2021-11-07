function []=logsheetPathButtonPushed(src)

%% PURPOSE: OPEN THE UI FILE PICKER WHEN THE BUTTON IS CLICKED. THEN PUT THE PATH INTO THE LOGSHEET PATH FIELD AND RUN THAT CALLBACK

% If a data (should it be code?) directory was already provided, open the file picker to that folder path.
fig=ancestor(src,'figure','toplevel');

dataPath=getappdata(fig,'dataPath'); % dataPath always begins empty.
% codePath=getappdata(fig,'codePath'); % codePath always begins empty.
[file,path]=uigetfile({'*.xlsx';'*.xls'},'Select the logsheet file',dataPath);
if isequal(file,0) && isequal(path,0) % 'Cancel' or 'Close' button was clicked
    return;
end

logsheetPath=[path file];
setappdata(fig,'logsheetPath',logsheetPath);
disp(logsheetPath);

% Set the logsheetPathField to display the new path
fig.Children.Children(1,1).Children(11,1).Value=logsheetPath;

% Run the logsheetPathFieldValueChanged callback.
logsheetPathFieldValueChanged(fig.Children.Children(1,1).Children(11,1));
