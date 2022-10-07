function []=switchProjectsDropDownValueChanged(src,event)

tic;
%% PURPOSE: WHEN CHANGING PROJECTS (ADDING NEW OR SWITCHING) PROPAGATE PROJECT SETTINGS TO THE REST OF THE GUI

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=handles.Projects.switchProjectsDropDown.Value;
setappdata(fig,'projectName',projectName);
setappdata(fig,'switchingProjects',1);

% 1. Load the project-specific settings MAT file (if it exists)
% Get the path to that file from the project-independent settings MAT file.
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
if exist(settingsMATPath,'file')~=2
    resetProjectAccess_Visibility(fig,1);   
    disp(['Project-specific settings file path could not be found in project-independent settings MAT file (project variable missing)']);
    disp(['To resolve, either enter the Code Path for this project, or check the settings MAT files']);
    setappdata(fig,'codePath','');
    codePathFieldValueChanged(fig); % Changing the code folder path changes all project-specific settings.
    return;
end

varNames=who('-file',settingsMATPath); % Get the list of all projects in the project-independent settings MAT file (each one is one variable).
projectNames=varNames(~ismember(varNames,{'mostRecentProjectName','currTab','version'})); % Remove the most recent project name from the list of variables in the settings MAT file

if ~ismember(projectName,projectNames)
    disp(['Unknown error: project name ' projectName ' not found in the list of projects. Try restarting the GUI']);
    return;
end

settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);
macAddress=getComputerID();

if ~isfield(settingsStruct,macAddress) % This project has never been accessed on this computer.
    resetProjectAccess_Visibility(fig,1);
    setappdata(fig,'codePath','');
    disp(['Project-specific settings file path for this computer could not be found in project-independent settings MAT file (computer hostname missing in project variable)']);
    codePathFieldValueChanged(fig); % Changing the code folder path changes all project-specific settings.
    return;
end

projectSettingsMATPath=settingsStruct.(macAddress).projectSettingsMATPath; % Get the file path of the project-specific settings MAT file
if contains(projectSettingsMATPath,'_RunLog')
    projectSettingsMATPath=[projectSettingsMATPath(1:end-11) '.mat'];
end

setappdata(fig,'projectSettingsMATPath',projectSettingsMATPath); % Change the project-specific settings file being referenced for saving.

if exist(projectSettingsMATPath,'file')~=2 % If the project-specific settings MAT file does not exist
    handles.Projects.codePathField.Value='Path to Project Processing Code Folder';
    handles.Projects.dataPathField.Value='Data Path (contains ''Raw Data Files'' folder)';
    resetProjectAccess_Visibility(fig,1);
    setappdata(fig,'codePath','');
    codePathFieldValueChanged(fig); % Changing the code folder path changes all project-specific settings.
    disp(['The path to the project-specific settings file is not valid. To fix, you can:']);
    disp(['(1) Enter a new code folder path,']);
    disp(['(2) Ensure that the project settings MAT file exists in the current code folder,']);
    disp(['(3) Check the accuracy of the project-independent settings MAT file located at: ' settingsMATPath]);
    return;
end

if getappdata(fig,'isRunLog')
    if ~contains(projectSettingsMATPath,'_RunLog')
        projectSettingsMATPath=[projectSettingsMATPath(1:end-4) '_RunLog.mat'];
    end
%     setappdata(fig,'projectSettingsMATPath',projectSettingsMATPath); % Saves an alternate version
end

if exist(projectSettingsMATPath,'file')~=2
    return;
end

load(projectSettingsMATPath,'NonFcnSettingsStruct');
setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);

%% NEED TO: ADD THE PATH OF THE CURRENT PROJECT (CODE & DATA FOLDERS) & REMOVE ALL OTHER PROJECTS FROM THE PATH.



%% Projects tab
if isfield(NonFcnSettingsStruct.Projects.Paths,macAddress)
    if isfield(NonFcnSettingsStruct.Projects.Paths.(macAddress),'CodePath')
        codePath=NonFcnSettingsStruct.Projects.Paths.(macAddress).CodePath;
    else
        codePath='Path to Project Processing Code Folder';
    end
    if isfield(NonFcnSettingsStruct.Projects.Paths.(macAddress),'DataPath')
        dataPath=NonFcnSettingsStruct.Projects.Paths.(macAddress).DataPath;
    else
        dataPath='Data Path (contains ''Raw Data Files'' folder)';
    end
else
    codePath='Path to Project Processing Code Folder';
    dataPath='Data Path (contains ''Raw Data Files'' folder)';
end

addpath(genpath(codePath));

slash=filesep;

if exist(codePath,'dir')==7
    if ~isequal(codePath(end),slash)
        codePath=[codePath slash]; % Ensure that there is always a slash at the end of the path.
    end
    setappdata(fig,'codePath',codePath);
    handles.Projects.codePathField.Value=codePath;
else
    resetProjectAccess_Visibility(fig,1);
    setappdata(fig,'codePath','');
    handles.Projects.codePathField.Value='Path to Project Processing Code Folder';
    return;
end

initializeLog(fig);
logPath=getappdata(fig,'runLogPath');
if exist(logPath,'file')==2
    setappdata(fig,'logEverCreated',true);
end

if exist(dataPath,'dir')==7
    if ~isequal(dataPath(end),slash)
        dataPath=[dataPath slash]; % Ensure that there is always a slash at the end of the path.
    end
    setappdata(fig,'dataPath',dataPath);
    handles.Projects.dataPathField.Value=dataPath;
else
    resetProjectAccess_Visibility(fig,2);
    setappdata(fig,'dataPath','');
    handles.Projects.dataPathField.Value='Data Path (contains ''Raw Data Files'' folder)';
    return;
end

if ~ismember('currTab',varNames)
    currTab='Projects';
else
    load(settingsMATPath,'currTab');
end
hTab=findobj(handles.Tabs.tabGroup1,'Title',currTab);
handles.Tabs.tabGroup1.SelectedTab=hTab;
version=getappdata(fig,'version');
save(settingsMATPath,'version','-append');
setappdata(fig,'currTab',currTab);

if ~isfield(NonFcnSettingsStruct.Projects,'ArchiveData')
    NonFcnSettingsStruct.Projects.ArchiveData=0;
else
    handles.Projects.archiveDataCheckbox.Value=NonFcnSettingsStruct.Projects.ArchiveData;
end

%% Import tab
logsheetPath=NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath;
handles.Import.numHeaderRowsField.Value=NonFcnSettingsStruct.Import.NumHeaderRows;
handles.Import.subjIDColHeaderField.Value=NonFcnSettingsStruct.Import.SubjectIDColHeader;
handles.Import.targetTrialIDColHeaderField.Value=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;
handles.Import.logsheetPathField.Value=logsheetPath;

projectSettingsVars=whos('-file',projectSettingsMATPath);
projectSettingsVarNames={projectSettingsVars.name};

if ismember('Digraph',projectSettingsVarNames)
    load(projectSettingsMATPath,'Digraph');
    setappdata(fig,'Digraph',Digraph);
end

if exist(logsheetPath,'file')==2    
    setappdata(fig,'logsheetPath',handles.Import.logsheetPathField.Value);
    resetProjectAccess_Visibility(fig,4); % Allow all tabs to be used.
    logsheetPathFieldValueChanged(fig,logsheetPath);
    varName=handles.Import.logVarsUITree.SelectedNodes.Text;
    handles.Import.trialSubjectDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(varName).TrialSubject;
    handles.Import.dataTypeDropDown.Value=NonFcnSettingsStruct.Import.LogsheetVars.(varName).DataType;
else
    resetProjectAccess_Visibility(fig,3); % Disallow loading info from logsheet.
    setappdata(fig,'logsheetPath','');
end

%% Process tab
% Delete all graphics objects in the plot, and all splits nodes
h=findobj(handles.Process.mapFigure,'Type','GraphPlot');
delete(h);
delete(handles.Process.splitsUITree.Children);
delete(handles.Process.fcnArgsUITree.Children);

delete(handles.Process.varsListbox.Children); % Remove all variables from other projects.

% Fill in metadata
if ismember('VariableNamesList',projectSettingsVarNames)
    load(projectSettingsMATPath,'VariableNamesList');
    setappdata(fig,'VariableNamesList',VariableNamesList);
    [~,alphabetIdx]=sort(upper(VariableNamesList.GUINames));
    makeVarNodes(fig,alphabetIdx,VariableNamesList);       
end

if ismember('Digraph',projectSettingsVarNames)    
    h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.447 0.741],'Interpreter','none');
    if ~isempty(Digraph.Edges)
        h.EdgeColor=Digraph.Edges.Color;
    end
end

if ~isfield(NonFcnSettingsStruct,'Process')
    return;
end

getSplitNames(NonFcnSettingsStruct.Process.Splits,[],handles.Process.splitsUITree);

%% Plot tab
if ismember('Plotting',projectSettingsVarNames)
    load(projectSettingsMATPath,'Plotting');
end
if isempty(Plotting)
    Plotting.Components.Names={'Axes'};
%     defVals=getProps('axes');
%     Plotting.Components.DefaultProperties{1}=defVals;
end

if ~ismember('Axes',Plotting.Components.Names)
    Plotting.Components.Names=[Plotting.Components.Names; {'Axes'}];
    [~,idx]=sort(upper(Plotting.Components.Names));
    Plotting.Components.Names=Plotting.Components.Names(idx);
%     defVals=getProps('axes');
%     Plotting.Components.DefaultProperties=[Plotting.Components.DefaultProperties; {defVals}];
%     Plotting.Components.DefaultProperties=Plotting.Components.DefaultProperties(idx);
end
setappdata(fig,'Plotting',Plotting);

makeCompNodes(fig,1:length(Plotting.Components.Names),Plotting.Components.Names);

if isfield(Plotting,'Plots') && ~isempty(fieldnames(Plotting.Plots))
    plotNames=fieldnames(Plotting.Plots);
    makePlotNodes(fig,1:length(plotNames),plotNames);
end

%% Stats tab
if ismember('Stats',projectSettingsVarNames)
    load(projectSettingsMATPath,'Stats');
else
    Stats='';
end
if isempty(Stats)
    Stats.Tables=struct();
    Stats.Functions={};
end

setappdata(fig,'Stats',Stats);

makeVarNodesStats(fig,alphabetIdx,VariableNamesList); 

% Set list of stats tables
tableNames=fieldnames(Stats.Tables);
makeTableNodes(fig,1:length(tableNames),tableNames);

% Set list of summary functions
makeStatsFcnNodes(fig,1:length(Stats.Functions),Stats.Functions);

% For first stats table, initialize the assignedVarsUITree
if ~isempty(handles.Stats.tablesUITree.Children)
    handles.Stats.tablesUITree.SelectedNodes=handles.Stats.tablesUITree.Children(1);
end
tablesUITreeSelectionChanged(fig);


%% Finalize setup
% 5. Set the most recent project to the current project name.
mostRecentProjectName=projectName;
save(getappdata(fig,'settingsMATPath'),'mostRecentProjectName','-append');

% 6. Store all of the project-specific settings to the GUI.
% setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);
% setappdata(fig,'FcnSettingsStruct',FcnSettingsStruct);

% 8. Tell the user that the project has successfully switched
drawnow;
a=toc;
setappdata(fig,'switchingProjects',0);
disp(['Success! Switched to project ' projectName ' in ' num2str(a) ' seconds']);