function []=removeProjectButtonPushed(src,event)

%% PURPOSE: REMOVE A PROJECT FROM THE DROP-DOWN LIST (AND FROM THE PROJECT-INDEPENDENT SETTINGS FILE)
% NOTE: THIS DOES NOT DELETE ANY FILES RELATED TO THE PROJECT ITSELF

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectNames=handles.Projects.switchProjectsDropDown.Items;

if length(projectNames)==1
    disp('Cannot delete the only project! Nothing removed');
    return;
end

settingsMATPath=getappdata(fig,'settingsMATPath'); % The project-independent settings
projectName=handles.Projects.switchProjectsDropDown.Value;

disp(['Removing project ' projectName]);

a=load(settingsMATPath);
a=rmfield(a,projectName);

projectNames=projectNames(~ismember(projectNames,projectName));

a.mostRecentProjectName=projectNames{1};

handles.Projects.switchProjectsDropDown.Items=projectNames;
handles.Projects.switchProjectsDropDown.Value=projectNames{1};

save(settingsMATPath,'-struct','a');

disp(['Switching to project ' projectNames{1}]);
switchProjectsDropDownValueChanged(fig);