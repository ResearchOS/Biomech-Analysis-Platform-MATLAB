function []=dataPathButtonPushed(src)

%% PURPOSE: OPEN THE UI FOLDER PICKER WHEN BUTTON IS PUSHED ON IMPORT TAB. PUT THE FILE PATH INTO THE DATA PATH FIELD

fig=ancestor(src,'figure','toplevel');

dataPath=getappdata(fig,'dataPath'); % dataPath always begins empty
path=uigetdir(dataPath,'Select the data folder');
if isequal(path,0) % 'Cancel' or 'Close' button was clicked.
    return;
end

dataPath=path;
setappdata(fig,'dataPath',dataPath);
disp(dataPath);

% Set the dataPathField to display the new path.
fig.Children.Children(1,1).Children(10,1).Value=dataPath;

% Run the dataPathFieldValueChanged callback
dataPathFieldValueChanged(fig.Children.Children(1,1).Children(10,1));