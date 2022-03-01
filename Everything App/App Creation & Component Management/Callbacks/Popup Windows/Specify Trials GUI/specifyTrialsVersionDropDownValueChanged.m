function []=specifyTrialsVersionDropDownValueChanged(src,event)

%% PURPOSE: SWITCH ALL SPECIFY TRIALS CRITERIA SHOWING BASED ON PRESET CONFIGURATIONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
specifyTrialsPath=getappdata(fig,'allProjectsSpecifyTrialsPath');

if exist(specifyTrialsPath,'file')~=2
    return; % If the text file does not exist, don't do anything.
end

value=handles.Top.specifyTrialsDropDown.Value;
