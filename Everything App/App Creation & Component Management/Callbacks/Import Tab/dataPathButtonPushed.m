function []=dataPathButtonPushed(src)

%% PURPOSE: OPEN THE UI FOLDER PICKER WHEN BUTTON IS PUSHED ON IMPORT TAB. PUT THE FILE PATH INTO THE DATA PATH FIELD

fig=ancestor(src,'figure','toplevel');

dataPath=getappdata(fig,'dataPath'); % dataPath always begins empty
path=uigetdir(dataPath,'Select the data folder');
if isequal(path,0) % 'Cancel' or 'Close' button was clicked.
    return;
end

dataPath=path;
if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end
if ~isequal(dataPath(end),slash)
    dataPath=[dataPath slash];
end
setappdata(fig,'dataPath',dataPath);
disp(['Data Path:' dataPath]);

% Set the dataPathField to display the new path.
h=findobj(fig,'Type','uieditfield','Tag','DataPathField');
h.Value=dataPath;

% Run the dataPathFieldValueChanged callback
dataPathFieldValueChanged(h);