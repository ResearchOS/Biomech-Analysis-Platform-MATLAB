function []=switchProjectsDropDownValueChanged(src,event)

tic;
%% PURPOSE: WHEN CHANGING PROJECTS (ADDING NEW OR SWITCHING) PROPAGATE PROJECT SETTINGS TO THE REST OF THE GUI

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=handles.Import.switchProjectsDropDown.Value;
setappdata(fig,'projectName',projectName);

% 1. Load the project-specific settings MAT file (if it exists)
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
projectNames=who('-file',settingsMATPath); % Get the list of all projects in the project-independent settings MAT file (each one is one variable).
projectNames=projectNames(~ismember(projectNames,{'mostRecentProjectName','currTab','version'})); % Remove the most recent project name from the list of variables in the settings MAT file

if ismember(projectName,projectNames)
    settingsStruct=load(settingsMATPath,projectName);
    settingsStruct=settingsStruct.(projectName);

    [~,macAddress]=system('ifconfig en0 | grep ether'); % Get the name of the current computer
    macAddress=genvarname(macAddress); % Generate a valid MATLAB variable name from the computer host name.

    if isfield(settingsStruct,macAddress)
        projectSettingsMATPath=settingsStruct.(macAddress).projectSettingsMATPath;

        if exist(projectSettingsMATPath,'file')==2
            NonFcnSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct');
            NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;
            codePath=NonFcnSettingsStruct.Import.Paths.(macAddress).CodePath;
        else
            codePath='';
        end

    else
        codePath='';
    end    

else
    codePath='';
end

% 2. Check if the project already exists. If not, need to make all the components invisible.
if ~ismember(projectName,projectNames) || (ismember(projectName,projectNames) && exist(codePath,'dir')~=7)
    % Turn off visibility for everything except new project & code path components
    tabNames=fieldnames(handles);
    tabNames=tabNames(~ismember(tabNames,'Tabs'));
    for tabNum=1:length(tabNames) % Iterate through every tab
        compNames=fieldnames(handles.(tabNames{tabNum}));
        for compNum=1:length(compNames)
            if ~(isequal(tabNames{tabNum},'Import') && ismember(handles.(tabNames{tabNum}).(compNames{compNum}).Tag,{'ProjectNameLabel','AddProjectButton','SwitchProjectsDropDown','CodePathButton','CodePathField'}))
                if ~isequal(handles.(tabNames{tabNum}).(compNames{compNum}).Tag,'TabGroup')
                    handles.(tabNames{tabNum}).(compNames{compNum}).Visible=0;
                end
            end
        end
    end
    handles.Import.codePathField.Value='Path to Project Processing Code Folder';
    return;
else
    % Turn all component visibility on.
    tabNames=fieldnames(handles);
    tabNames=tabNames(~ismember(tabNames,'Tabs'));
    for tabNum=1:length(tabNames) % Iterate through every tab
        compNames=fieldnames(handles.(tabNames{tabNum}));
        for compNum=1:length(compNames)
            if ~isequal(handles.(tabNames{tabNum}).(compNames{compNum}).Tag,'TabGroup')
                handles.(tabNames{tabNum}).(compNames{compNum}).Visible=1;
            end
        end
    end
end

% 3. Change the GUI fields unrelated to functions & arguments
handles.Import.codePathField.Value=codePath;
handles.Import.dataPathField.Value=NonFcnSettingsStruct.Import.Paths.(macAddress).DataPath;
handles.Import.logsheetPathField.Value=NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath;
handles.Import.numHeaderRowsField.Value=NonFcnSettingsStruct.Import.NumHeaderRows;
handles.Import.subjIDColHeaderField.Value=NonFcnSettingsStruct.Import.SubjectIDColHeader;
handles.Import.targetTrialIDColHeaderField.Value=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;
handles.Plot.rootSavePathEditField.Value=NonFcnSettingsStruct.Plot.RootSavePath;

if exist(handles.Import.dataPathField.Value,'dir')==7
    setappdata(fig,'dataPath',handles.Import.dataPathField.Value);
else
    setappdata(fig,'dataPath','');
end

if exist(handles.Import.logsheetPathField.Value,'file')==2
    setappdata(fig,'logsheetPath',handles.Import.logsheetPathField.Value);
else
    setappdata(fig,'logsheetPath','');
end

% 4. Change the GUI fields related to functions & arguments
% Import tab: If no data types have been entered yet, then regardless of whether there are functions in the processing folder, make invisible the
% buttons on the left side of the screen besides "D+"
    % If there is at least one data type, ensure that all of the buttons are visible.
if exist(projectSettingsMATPath,'file')==2
    load(projectSettingsMATPath,'FcnSettingsStruct'); % Don't "double access" this variable because it will likely get rather large.
end

tabNames={'Import','Process','Plot'};
groupingNames={'DataTypes','Groups','PlotTypes'};
for tabNum=1:3 % Import, Process, Plot

    tabName=tabNames{tabNum};
    groupingName=groupingNames{tabNum};
    fcnUITree=handles.(tabName).functionsUITree; % The current tab's function UI tree
    argUITree=handles.(tabName).argumentsUITree; % The current tab's argument UI tree

    % Clear the UI tree objects when switching projects.
    delete(fcnUITree.Children);
    delete(argUITree.Children);

    parentGroupedNodes=FcnSettingsStruct.(tabName).(groupingName);
    if ~(length(parentGroupedNodes)==1 && isempty(parentGroupedNodes{1}))        
        for parentNodeNum=1:length(parentGroupedNodes) % If there are any parent grouping nodes, build the UI tree
            parentNode=parentGroupedNodes{parentNodeNum};
            uitreenode(fcnUITree,'Text',parentNode);
            % Build the nodes under that parent node
            childNodes=fieldnames(FcnSettingsStruct.(tabName).FcnUITree.(parentNode));
            for childNodeNum=1:length(childNodes)

            end
        end
    end

    allFcns=FcnSettingsStruct.(tabName).FcnUITree.All;
    if ~(length(allFcns)==1 && isempty(allFcns{1}))
        allFcnsNode=uitreenode(fcnUITree,'Text','All'); % Initialize the "All" parent node
        for i=1:length(allFcns) % If there are any functions at all, regardless of having been assigned a group.
            uitreenode(allFcnsNode,'Text',allFcns{i});
        end
    end

    allArgs=FcnSettingsStruct.(tabName).ArgsUITree.All;
    if ~(length(allArgs)==1 && isempty(allArgs{1}))
        allArgsNode=uitreenode(argUITree,'Text','All');
        for i=1:length(allArgs) % If there are any arguments at all, regardless of having been assigned a group
            uitreenode(allArgsNode,'Text',allArgs{i});
        end
    end
end

% 5. Set the most recent project to the current project name.
mostRecentProjectName=projectName;
save(getappdata(fig,'settingsMATPath'),'mostRecentProjectName','-append');

% 6. Store all of the project-specific settings to the GUI.
setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);
setappdata(fig,'FcnSettingsStruct',FcnSettingsStruct);

% 7. Tell the user that the project has successfully switched
drawnow;
a=toc;
disp(['Success! Switched to project ' projectName ' in ' num2str(a) ' seconds']);