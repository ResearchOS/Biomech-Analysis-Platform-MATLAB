function []=codePathButtonPushed(src)

%% PURPOSE: OPEN A UI FOLDER PICKER AND STORE THE RESULT INTO THE CODE PATH EDIT FIELD

fig=ancestor(src,'figure','toplevel');

codePath=getappdata(fig,'codePath'); % dataPath always begins empty
path=uigetdir(codePath,'Select the code folder');
if isequal(path,0) % 'Cancel' or 'Close' button was clicked.
    return;
end

codePath=path;
setappdata(fig,'codePath',codePath);
disp(codePath);

% Set the dataPathField to display the new path.
h=findobj(fig,'Type','uieditfield','Tag','CodePathField');
h.Value=codePath;

% Run the dataPathFieldValueChanged callback
codePathFieldValueChanged(h);