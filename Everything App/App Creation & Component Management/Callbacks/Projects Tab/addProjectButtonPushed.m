function []=addProjectButtonPushed(src,projectName)

%% PURPOSE: CREATE A NEW PROJECT. COULD BE FIRST TIME USE (NO EXISTING PROJECTS, ALL COMPONENTS INVISIBLE), OR JUST A NEW PROJECT (ALL COMPONENTS VISIBLE)

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% 1. Prompt for the name of the new project
while true
    if exist('projectName','var')~=1
        projectName=inputdlg('Enter the new project name','New Project Name');
        runLog=true;
    else
        projectName={projectName};
        runLog=false;
    end

    if isempty(projectName) || isempty(projectName{1})
        return; % Pressed Cancel, or did not enter anything.
    end

    projectName=projectName{1};

    if isvarname(projectName)        
        break;
    elseif ~runLog
        clear projectName; % Prevents an infinite loop if the project name in the log is not correct.
    end

    disp(['Project name needs to be valid variable name!']);

end

resetProjectAccess_Visibility(fig,0);

% Create a struct for the new project (to be located in the project-independent settings folder)
macAddress=getComputerID();
settingsStruct.(macAddress).projectSettingsMATPath=''; % Temporary variable just to create an empty structure for the project with one empty field for the current computer's hostname.
eval([projectName '=settingsStruct;']); % Name the variable according to the current project name. One variable per project in the MAT file. 

%% 2. Set the most recent project name and the current project name. Store in GUI and save to file.
setappdata(fig,'projectName',projectName);
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path

varNames=whos('-file',settingsMATPath);
varNames={varNames.name};

if ismember(projectName,varNames)
    disp('Project already exists!');
    return;
end

% Save to project-independent settings MAT file
mostRecentProjectName=projectName;
if exist(settingsMATPath','file')==2
    save(settingsMATPath,'mostRecentProjectName',projectName,'-mat','-append'); % Save the most recent (i.e. current) project name, and the project's settings struct with the path name to the code folder
else
    save(settingsMATPath,'mostRecentProjectName',projectName,'-mat','-v6');
end

%% 3. Add project name to project drop down list
projList=handles.Projects.switchProjectsDropDown.Items; % Get the list of current projects

if length(projList)==1 && isequal(projList{1},'New Project')
    handles.Projects.switchProjectsDropDown.Items={projectName};
else
    handles.Projects.switchProjectsDropDown.Items=[handles.Projects.switchProjectsDropDown.Items {projectName}];
end

handles.Projects.switchProjectsDropDown.Value=projectName;

%% 4. Add visibility of the code path edit field (if not already visible)
resetProjectAccess_Visibility(fig,1);
handles.Projects.codePathField.Value='Path to Project Processing Code Folder';

disp('Next, select or enter the full path to the folder where all of the code for this project will be stored.');

if runLog
    desc='Create the project';
    updateLog(fig,desc,projectName);
end