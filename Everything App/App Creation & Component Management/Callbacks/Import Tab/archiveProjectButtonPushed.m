function []=archiveProjectButtonPushed(src,event)

%% PERMANENTLY DELETE A PROJECT. IN THE FUTURE, PLAN TO ARCHIVE PROJECTS INSTEAD, BUT FOR NOW IT'S HELPFUL FOR TESTING TO BE ABLE TO DELETE A PROJECT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

isSure=questdlg({'Are you sure you want to delete this project?',projectName},projectName,'Yes','No','No');

if ~isequal(isSure,'Yes')
    disp(['Project ' projectName ' NOT deleted']);
    return;
end

settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
projectNames=who('-file',settingsMATPath); % Get the list of all projects in the project-independent settings MAT file (each one is one variable).
projectNames=projectNames(~ismember(projectNames,{'mostRecentProjectName','currTab','version',projectName})); % Remove the most recent project name from the list of variables in the settings MAT file

if isempty(projectNames) % If the last project is deleted, then delete the whole project-independent settings file and re-open the GUI to re-initialize everything
    delete(settingsMATPath); 
    close(fig);
    pgui; % This is a cheap way of re-initializing the GUI components after the last project was deleted.
    return;
end

mostRecentProjectName=projectNames{1}; % Set the most recent project name to the first project name in the list.

% [~,hostname]=system('hostname'); % Get the name of the current computer
% hostVarName=genvarname(hostname); % Generate a valid MATLAB variable name from the computer host name.

for i=1:length(projectNames) % For each project to keep

    currProject=load(settingsMATPath,projectNames{i}); % Load the project
    currProject=currProject.(projectNames{i});
%     currProject=rmfield(currProject,hostVarName);
%     if isempty(fieldnames(currProject)) % Project removed from all computers
%         
%     end
    eval([projectNames{i} '=currProject;']); % Dynamically name the variable

end

% Delete project-specific settings
% settingsStruct=load(settingsMATPath,projectName);

% [~,hostname]=system('hostname'); % Get the name of the current computer
% hostVarName=genvarname(hostname); % Generate a valid MATLAB variable name from the computer host name.

% projectSettingsMATPath=settingsStruct.(hostVarName).projectSettingsMATPath;

% if exist(projectSettingsMATPath,'file')==2
%     delete(projectSettingsMATPath);
% end

if size(projectNames,1)>size(projectNames,2) % Column major
    projectNames=projectNames';
end

currTab=handles.Tabs.tabGroup1.SelectedTab.Title;

load(settingsMATPath,'version');

save(settingsMATPath,projectNames{:},'mostRecentProjectName','currTab','version','-v6'); % Save all of the projects that are not being deleted.

setappdata(fig,'projectName',mostRecentProjectName);
handles.Import.switchProjectsDropDown.Items=projectNames;
handles.Import.switchProjectsDropDown.Value=mostRecentProjectName;

disp(['Successfully deleted project ' projectName]);

switchProjectsDropDownValueChanged(fig);