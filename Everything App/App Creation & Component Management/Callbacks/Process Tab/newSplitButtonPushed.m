function []=newSplitButtonPushed(src,event)

%% PURPOSE: CREATE A NEW SPLIT, WHETHER FOR EXISTING OR NEW FUNCTIONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

while true

    name=inputdlg('Enter Split Name','New Split Name');
    if isempty(name)
        return;
    end

    name=name{1};

    if isvarname(name)
        break;                
    end

    disp('Split name must be valid MATLAB variable name!');

end

% Can I have an empty split with nothing in it? Or does a split need to be
% initialized with a function in it?
projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'NonFcnSettingsStruct');

NonFcnSettingsStruct.Process.Splits.(name).Code=genSplitCode(projectSettingsMATPath,name);