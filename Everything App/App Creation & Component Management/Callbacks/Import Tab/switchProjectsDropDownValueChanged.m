function []=switchProjectsDropDownValueChanged(src)

%% PURPOSE: IF THE SELECTED PROJECT IN THE DROP DOWN CHANGED, THEN PROPAGATE THOSE CHANGES TO THE EDIT FIELDS IN THE IMPORT TAB.

% data=src.Value;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% Set the project name field according to the current drop down selection
% h=findobj(fig,'Type','uidropdown','Tag','SwitchProjectsDropDown');
h=handles.Import.switchProjectsDropDown;
% h.Value=getappdata(fig,'projectName');

projectName=h.Value;
% projectName=handles.Import.switchProjectsDropDown;
setappdata(fig,'projectName',projectName)

if isequal(projectName,'New Project')
    visState='off';
    setappdata(fig,'EmptyProjectName',1); % Indicates that the project name field is empty when the app was initialized.
else
    visState='on';
    setappdata(fig,'EmptyProjectName',0);
end

% Once a project name has been created, make everything visible!
projNameLabel=handles.Import.projectNameLabel;
projNameDropDown=handles.Import.switchProjectsDropDown;
addProjButton=handles.Import.addProjectButton;
% projNameLabel=findobj(fig,'Type','uilabel','Tag','ProjectNameLabel');
% projNameDropDown=findobj(fig,'Type','uidropdown','Tag','SwitchProjectsDropDown');
% addProjButton=findobj(fig,'Type','uibutton','Tag','AddProjectButton');

% h=findall(fig.Children.Children(1,1));
h=findall(fig);
for i=1:length(h)
    if ismember(h(i),[projNameLabel projNameDropDown addProjButton fig]) % Ignore the project name textbox and label.
        h(i).Visible='on';
    else
        if ~ismember(h(i).Type,{'uitab','uitabgroup'}) % Because these components don't have a Visible property.
            h(i).Visible=visState;
        end
    end
end

if getappdata(fig,'EmptyProjectName')==1
    return;
end

fileName=getappdata(fig,'allProjectsTxtPath'); % Get the 'allProjects_ProjectNamesPaths.txt' path.
everythingPath=getappdata(fig,'everythingPath');

A=readAllProjects(getappdata(fig,'everythingPath')); % Return the text of the 'allProjects_ProjectNamesPaths.txt' file
if iscell(A)
    allProjectsList=getAllProjectNames(A);
    existingProject=1;
else
    existingProject=0;
end


hLog=handles.Import.logsheetPathField;
hData=handles.Import.dataPathField;
hCode=handles.Import.codePathField;
hRootSave=handles.Plot.rootSavePlotPathField;
hNumHeaderRows=handles.Import.numHeaderRowsField;
hSubjIDColHeader=handles.Import.subjIDColHeaderField;
hTrialIDColHeaderDataType=handles.Import.trialIDColHeaderDataTypeField;
hTargetTrialColHeader=handles.Import.targetTrialIDColHeaderField;
hDataTypesDropDown=handles.Import.dataTypeImportSettingsDropDown;
hDataTypeMethodField=handles.Import.dataTypeImportMethodField;
hSpecifyTrialsNumberField=handles.Import.specifyTrialsNumberField;

% hLog=findobj(fig,'Type','uieditfield','Tag','LogsheetPathField');
% hData=findobj(fig,'Type','uieditfield','Tag','DataPathField');
% hCode=findobj(fig,'Type','uieditfield','Tag','CodePathField');
% hRootSave=findobj(fig,'Type','uieditfield','Tag','RootSavePlotPathField');
% hNumHeaderRows=findobj(fig,'Type','uinumericeditfield','Tag','NumHeaderRowsField');
% hSubjIDColHeader=findobj(fig,'Type','uieditfield','Tag','SubjIDColumnHeaderField');
% hTrialIDColHeaderDataType=findobj(fig,'Type','uieditfield','Tag','DataTypeTrialIDColumnHeaderField');
% hTargetTrialColHeader=findobj(fig,'Type','uieditfield','Tag','TargetTrialIDColHeaderField');
% hDataTypesDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown'); % Data types drop down
% hDataTypeMethodField=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField'); % Data types method number & letter edit field
% hSpecifyTrialsNumberField=findobj(fig,'Type','uieditfield','Tag','SpecifyTrialsNumberField');
% hGroupsDataToLoad=findobj(fig,'Type','uipanel','Tag','SelectDataPanel'); % Panel encompassing the groups' data to load
% If the project was pre-existing in the all projects file
if existingProject==1
    projectNameInfo=isolateProjectNamesInfo(A,projectName); % Return the path names associated with the specified project name.
    
    % Set those path names into the figure's app data, & update the displays
    % Logsheet Path
    if isfield(projectNameInfo,'LogsheetPath')
        setappdata(fig,'logsheetPath',projectNameInfo.LogsheetPath);
        hLog.Value=getappdata(fig,'logsheetPath');        
    else % Set to default
        setappdata(fig,'logsheetPath','');
        hLog.Value='Set Logsheet Path';
        setappdata(fig,'subjectCodenameColumnNum',0);
    end    
    
    % Data Path
    if isfield(projectNameInfo,'DataPath')
        setappdata(fig,'dataPath',projectNameInfo.DataPath);
        hData.Value=getappdata(fig,'dataPath');        
    else
        setappdata(fig,'dataPath','');
        hData.Value='Data Path (contains ''Subject Data'' folder)';
    end    
    
    % Code Path
    if isfield(projectNameInfo,'CodePath')
        setappdata(fig,'codePath',projectNameInfo.CodePath);
        hCode.Value=getappdata(fig,'codePath');        
    else
        setappdata(fig,'codePath','');
        hCode.Value='Path to Project Processing Code Folder';
    end    
    
    % Root Save Plot Path
    if isfield(projectNameInfo,'RootSavePlotPath')
        setappdata(fig,'rootSavePlotPath',projectNameInfo.RootSavePlotPath);
        hRootSave.Value=getappdata(fig,'rootSavePlotPath');
    else
        hRootSave.Value='Set Root Plot Save Path';
        setappdata(fig,'rootSavePlotPath','');
    end
    
    % Num Header Rows
    if isfield(projectNameInfo,'NumHeaderRows')
        setappdata(fig,'numHeaderRows',projectNameInfo.NumHeaderRows);
        hNumHeaderRows.Value=getappdata(fig,'numHeaderRows');
    else
        hNumHeaderRows.Value=0;
        setappdata(fig,'numHeaderRows',0);
    end
    
    % Subject ID Col Header
    if isfield(projectNameInfo,'SubjIDColHeader')
        setappdata(fig,'subjIDColHeader',projectNameInfo.SubjIDColHeader);
        hSubjIDColHeader.Value=getappdata(fig,'subjIDColHeader');
    else
        hSubjIDColHeader.Value='Set Subject ID Column Header';
        setappdata(fig,'subjIDColHeader','');
        setappdata(fig,'subjectCodenameColumnNum',0);
    end
    
    % Target Trial ID Col Header
    if isfield(projectNameInfo,'TargetTrialIDFormat')
        setappdata(fig,'targetTrialIDFormat',projectNameInfo.TargetTrialIDFormat);
        hTargetTrialColHeader.Value=getappdata(fig,'targetTrialIDFormat');
    else
        hTargetTrialColHeader.Value='Set Target Trial ID Col Header';
        setappdata(fig,'targetTrialIDFormat','');
    end
    
    % Data Types
    if isfield(projectNameInfo,'DataTypes')
        % Isolate the first data type and put that into the drop down and text box
        allTypes=strsplit(projectNameInfo.DataTypes,', ');
        for i=1:length(allTypes) % For each data type
            currType=strsplit(allTypes{i},' ');
            currTypeChar='';
            for j=1:length(currType)-1
                if j<=length(currType)-1 && j>1
                    mid=' ';
                else
                    mid='';
                end
                currTypeChar=[currTypeChar mid currType{j}];
            end
            if i==1
                alphaNumericIdx=isstrprop(currTypeChar,'alpha') | isstrprop(currTypeChar,'digit');
                startVal=lower(currTypeChar(alphaNumericIdx));
                startLetter=currType{end};
                startNumber=startLetter(~isletter(startLetter));
                startLetter=startLetter(isletter(startLetter));
                hDataTypeMethodField.Value=currType{end};
                hDataTypesDropDown.Items={currTypeChar};
                hDataTypesDropDown.Value=currTypeChar;
            else
                hDataTypesDropDown.Items=[hDataTypesDropDown.Items {currTypeChar}];
            end
        end
        hDataTypesDropDown.Items=sort(hDataTypesDropDown.Items);
    else
%         hTrialIDColHeaderDataTypeField=findobj(fig,'Type','uieditfield','Tag','DataTypeTrialIDColumnHeaderField');
        hTrialIDColHeaderDataTypeField=handles.Import.dataTypeTrialIDColHeaderField;
        hTrialIDColHeaderDataTypeField.Visible='off';
        hDataTypesDropDown.Items={'No Data Types to Import'};
    end
    
    % Trial ID Col Header
    dataType=hDataTypesDropDown.Value;
    alphaNumericIdx=isstrprop(dataType,'alpha') | isstrprop(dataType,'digit');
    dataType=dataType(alphaNumericIdx);
    if ~isempty(projectNameInfo)
        fldNames=fieldnames(projectNameInfo);
        for i=1:length(fldNames)
            if contains(fldNames{i},'TrialIDColHeader')
                fldName=fldNames{i};
                if isequal(fldName,['TrialIDColHeader' dataType])
                    hTrialIDColHeaderDataType.Value=projectNameInfo.(fldName);
                    break;
                end
            end
        end
    end
    
    % Groups Data to Load
    if isfield(projectNameInfo,'GroupsDataToLoad')
        setappdata(fig,'groupsDataToLoad',projectNameInfo.GroupsDataToLoad);
        %         hGroupsDataToLoad.Value=getappdata(fig,'groupsDataToLoad');
    else
        %         hGroupsDataToLoad.Value='Set Data To Load';
        setappdata(fig,'groupsDataToLoad','');
    end
    
    % Specify Trials Number
    if isfield(projectNameInfo,'SpecifyTrialsNumber')
%         setappdata(fig,'',projectNameInfo.SpecifyTrialsNumber);
        hSpecifyTrialsNumberField.Value=projectNameInfo.SpecifyTrialsNumber;
    else
        hSpecifyTrialsNumberField.Value='1';
%         setappdata(fig,'',0);
    end
    
    saveFile=0; % Indicates to not save the file again.
    for i=length(A):-1:1 % Go through each line of A, looking for the 'Most Recent Project Name'
        if length(A{i})>=length('Most Recent Project Name:') && isequal(A{i}(1:length('Most Recent Project Name:')),'Most Recent Project Name:')
            A{i}=['Most Recent Project Name: ' projectName];
            break;
        end
    end
    fid=fopen(fileName,'w');
    fprintf(fid,'%s\n',A{1:end-1});
    fprintf(fid,'%s',A{end});
    fclose(fid);
elseif existingProject==0
    % If not already existing, check if the allProjects file exists and/or make a new entry in the 'allProjects_ProjectNamesPaths.txt' file and save it.
    if exist(fileName,'file')~=2 % File does not exist.
        fid=fopen(fileName,'w'); % Create & open the file
        A{1}=['Project Name: ' projectName];
        A{2}='';
        A{3}=['Most Recent Project Name: ' projectName];
        fprintf(fid,'%s\n',A{1:end-1});
        fprintf(fid,'%s',A{end});
        fclose(fid); % Close the file
        saveFile=0; % Indicates to not save the file again.
    else % If file already exists, put new project at the end
        saveFile=1; % Indicates to save the file.
        A=readAllProjects(everythingPath);
        if iscell(A)
            mostRecent=A(end-1:end); % Isolate last two lines (empty & most recent project name)
            A(end)={['Project Name: ' projectName]}; % Replace last line with project name
            A(length(A)+1:length(A)+2)=mostRecent; % Add two more lines
        end
    end
    allProjectsList=getAllProjectNames(A);
    
    hTrialIDColHeaderDataTypesField=handles.Import.dataTypeTrialIDColumnHeaderField;
%     hTrialIDColHeaderDataTypesField=findobj(fig,'Type','uieditfield','Tag','DataTypeTrialIDColumnHeaderField');
    hTrialIDColHeaderDataTypesField.Visible='off';
    
    hDataTypesDropDown.Items={'No Data Types to Import'};
    
    % Set the other fields to their default values
    setappdata(fig,'logsheetPath','');
    hLog.Value='Set Logsheet Path';
    setappdata(fig,'dataPath','');
    hData.Value='Data Path (contains ''Subject Data'' folder)';
    setappdata(fig,'codePath','');
    hCode.Value='Path to Project Processing Code Folder';
    setappdata(fig,'rootSavePlotPath','');
    
end

% Run the callbacks to propagate changes
logsheetPathFieldValueChanged(hLog);
dataPathFieldValueChanged(hData);
codePathFieldValueChanged(hCode);

if ~exist('startVal','var')
    startVal='0';
    startLetter='0'; % Just to allow the search for a folder to fail when naming the buttons
    startNumber='0';
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

h=handles.Import.openGroupSpecifyTrialsButton;
% h=findobj(fig,'Type','uibutton','Tag','OpenSpecifyTrialsButton');
% Check if the new project's specifyTrials file exists. If not, label it
% 'Create'. If so, label it 'Open'
if exist([getappdata(fig,'codePath') 'Import_' projectName slash 'Specify Trials' slash 'specifyTrials_Import' hSpecifyTrialsNumberField.Value '.m'],'file')==2 % This file exists.
    prefix='Open';
else
    prefix='Create';
end
h.Text=[prefix ' specifyTrials_Import' hSpecifyTrialsNumberField.Value '.m'];

%% Set the entered project name as the most recently used project at the end of the file.
if saveFile==1 % Indicates to save the file
    mostRecentProjPrefix='Most Recent Project Name:';
    if iscell(A)
        for i=length(A):-1:1
            if length(A{i})>length(mostRecentProjPrefix) && isequal(A{i}(1:length(mostRecentProjPrefix)),mostRecentProjPrefix)
                A{i}=[mostRecentProjPrefix ' ' projectName];
                break;
            end
        end
        fid=fopen(fileName,'w');
        fprintf(fid,'%s\n',A{1:end-1});
        fprintf(fid,'%s',A{end});
        fclose(fid);
    end
end

dataType=hDataTypesDropDown.Value;
dataField=lower(dataType(isstrprop(dataType,'alpha') | isstrprop(dataType,'digit')));

% Change the prefix for the importMetadata button
hButton=handles.Import.openImportMetadataButton;
% hButton=findobj(fig,'Type','uibutton','Tag','OpenImportMetadataButton');
% Need to get the data type for the file name
if exist([getappdata(fig,'codePath') 'Import_' projectName slash 'Arguments' slash dataField '_Import' startNumber startLetter '.m'],'file')==2 % This file exists.
    prefix='Open';
else
    prefix='Create';
end
hButton.Text=[prefix ' Import Args ' dataType];

% Change the prefix for the Import fcn button
hButton=handles.Import.openImportFcnButton;
% hButton=findobj(fig,'Type','uibutton','Tag','OpenImportFcnButton');

% If the file exists in the library, the Existing Functions folder, or the user-created functions folder, label the button with 'Open', otherwise
% 'Create'
if exist([getappdata(fig,'codePath') 'Import_' projectName slash 'User-Created Functions' slash dataField '_Import' startNumber '.m'],'file')==2 || ...
        exist([getappdata(fig,'everythingPath') 'm File Library' slash 'Import' slash dataType slash dataField '_Import' startNumber '.m'],'file')==2 || ...
        exist([getappdata(fig,'codePath') 'Import_' projectName slash 'Existing Functions' slash dataField '_Import' startNumber '.m'],'file')==2 % This file exists.
    prefix='Open';
else
    prefix='Create';
end
hButton.Text=[prefix ' Import Fcn ' dataType];

%% Set up the entries in the uipanel
% Each entry gets two boxes: one to load that data, one to remove it.
% At the top is the data types, one entry per data type
hUpArrowDataPanelButton=handles.Import.dataPanelUpArrowButton;
% hUpArrowDataPanelButton=findobj(fig,'Type','uibutton','Tag','DataPanelUpArrowButton');
hUpArrowDataPanelButton.Visible='off';
hDownArrowDataPanelButton=handles.Import.dataPanelDownArrowButton;
% hDownArrowDataPanelButton=findobj(fig,'Type','uibutton','Tag','DataPanelDownArrowButton');
hDownArrowDataPanelButton.Visible='off';
addDataTypeEntry2Panel(fig);

hUpArrowProcessRunButton=handles.ProcessRun.processRunUpArrowButton;
% hUpArrowProcessRunButton=findobj(fig,'Type','uibutton','Tag','ProcessRunUpArrowButton');
hUpArrowProcessRunButton.Visible='off';
hDownArrowProcessRunButton=handles.ProcessRun.processRunDownArrowButton;
% hDownArrowProcessRunButton=findobj(fig,'Type','uibutton','Tag','ProcessRunDownArrowButton');
hDownArrowProcessRunButton.Visible='off';

% After that, is each function group. One entry=all data for one group

%% Read the function names file for this project. Set the Process > Setup group names drop-down items, value, and the function names text area.
[text]=readFcnNames(getappdata(fig,'fcnNamesFilePath'));
hGroupNamesDropDown=handles.ProcessSetup.setupGroupNameDropDown;
hGroupNamesRunDropDown=handles.ProcessRun.runGroupNameDropDown;
% hGroupNamesDropDown=findobj(fig,'Type','uidropdown','Tag','SetupGroupNameDropDown');
% hGroupNamesRunDropDown=findobj(fig,'Type','uidropdown','Tag','RunGroupNameDropDown');

if ~isempty(text)
    [groupNames,~,mostRecentSetupGroupName,mostRecentRunGroupName]=getGroupNames(text);
    
    if ~isempty(groupNames{1}) && isequal(groupNames{1},'Create Group Name')
        error(['Function names file is incorrect: ' getappdata(fig,'fcnNamesFilePath')]);
    end
    
    hGroupNamesDropDown.Items=groupNames;
    if ~isempty(mostRecentSetupGroupName)
        hGroupNamesDropDown.Value=mostRecentSetupGroupName;
    end
    setupGroupNamesDropDownValueChanged(hGroupNamesDropDown);
    
    %% Set the Process > Run group names drop-down items
    
    hGroupNamesRunDropDown.Items=groupNames;
    
    %% Set the Process > Run group names drop-down value
    if ~isempty(mostRecentRunGroupName)
        hGroupNamesRunDropDown.Value=mostRecentRunGroupName;
    end
    
    runGroupNameDropDownValueChanged(hGroupNamesRunDropDown);
else % If the text file is empty.
    hGroupNamesDropDown.Items={'Create Function Group'};
    setupGroupNamesDropDownValueChanged(hGroupNamesDropDown);
    
    hGroupNamesRunDropDown.Items={'Create Function Group'};
    runGroupNameDropDownValueChanged(hGroupNamesRunDropDown);
end

setappdata(fig,'handles',handles);