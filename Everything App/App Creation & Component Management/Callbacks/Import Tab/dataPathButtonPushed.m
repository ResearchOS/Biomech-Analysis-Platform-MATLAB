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
disp(['Data Path:' dataPath]);

% Set the dataPathField to display the new path.
h=findobj(fig,'Type','uieditfield','Tag','DataPathField');
h.Value=dataPath;

% Run the dataPathFieldValueChanged callback
dataPathFieldValueChanged(h);