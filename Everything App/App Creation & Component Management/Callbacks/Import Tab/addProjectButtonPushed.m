function []=addProjectButtonPushed(src,event)

%% PURPOSE: CREATE A NEW PROJECT. COULD BE FIRST TIME USE (NO EXISTING PROJECTS, ALL COMPONENTS INVISIBLE), OR JUST A NEW PROJECT (ALL COMPONENTS VISIBLE)

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% 1. Prompt for the name of the new project
isOKName=0; % Initialize that the new project name is not a valid MATLAB variable name.
while isOKName==0
    projectName=inputdlg('Enter the new project name','New Project Name');

    if isempty(projectName) || isempty(projectName{1})
        return; % Pressed Cancel, or did not enter anything.
    end

    projectName=projectName{1};

    if isvarname(projectName)
        isOKName=1;
    end

end

% Turn off visibility for everything except new project & code path components
tabNames=fieldnames(handles);
tabNames=tabNames(~ismember(tabNames,'Tabs'));
for tabNum=1:length(tabNames) % Iterate through every tab
    compNames=fieldnames(handles.(tabNames{tabNum}));
    for compNum=1:length(compNames)
        if ~(isequal(tabNames{tabNum},'Import') && ismember(handles.(tabNames{tabNum}).(compNames{compNum}).Tag,{'ProjectNameLabel','AddProjectButton','SwitchProjectsDropDown'}))
            handles.(tabNames{tabNum}).(compNames{compNum}).Visible=0;
        end
    end
end

% Create a struct for the new project (to be located in the project-independent settings folder)
[~,macAddress]=system('ifconfig en0 | grep ether'); % Get the name of the current computer
macAddress=genvarname(macAddress); % Generate a valid MATLAB variable name from the computer host name.
settingsStruct.(macAddress).projectSettingsMATPath=''; % Temporary variable just to create an empty structure for the project with one empty field for the current computer's hostname.
eval([projectName '=settingsStruct;']); % Name the variable according to the current project name. One variable per project in the MAT file. 

% 2. Set the most recent project name and the current project name. Store in GUI and save to file.
setappdata(fig,'projectName',projectName);
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path

% Save to project-independent settings MAT file
mostRecentProjectName=projectName;
if exist(settingsMATPath','file')==2
    save(settingsMATPath,'mostRecentProjectName',projectName,'-mat','-append'); % Save the most recent (i.e. current) project name, and the project's settings struct with the path name to the code folder
else
    save(settingsMATPath,'mostRecentProjectName',projectName,'-mat','-v6');
end

% 3. Add visibility of the code path edit field (if not already visible)
handles.Import.codePathButton.Visible=1;
handles.Import.codePathField.Visible=1;
handles.Import.codePathField.Value='Path to Project Processing Code Folder';

disp('Next, select or enter the full path to the folder where all of the code for this project will be stored.');

% 4. Add project name to project drop down list
projList=handles.Import.switchProjectsDropDown.Items; % Get the list of current projects

if length(projList)==1 && isequal(projList{1},'New Project')
    handles.Import.switchProjectsDropDown.Items={projectName};
else
    handles.Import.switchProjectsDropDown.Items=[handles.Import.switchProjectsDropDown.Items {projectName}];
end

handles.Import.switchProjectsDropDown.Value=projectName;