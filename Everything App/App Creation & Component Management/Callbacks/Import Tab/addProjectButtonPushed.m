function []=addProjectButtonPushed(src)

fig=ancestor(src,'figure','toplevel');

projectName=inputdlg('Enter the new project name','New Project Name');

if isempty(projectName) || isempty(projectName{1})
    return; % Pressed Cancel, or did not enter anything.
end

setappdata(fig,'projectName',projectName{1});

h=findobj(fig,'Type','uidropdown','Tag','SwitchProjectsDropDown');
if ~contains(h.Items,projectName)
    h.Items=[h.Items; projectName];
end
h.Value=projectName;

switchProjectsDropDownValueChanged(fig)