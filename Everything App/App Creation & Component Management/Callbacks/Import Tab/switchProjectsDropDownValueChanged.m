function []=switchProjectsDropDownValueChanged(src)

%% PURPOSE: IF THE SELECTED PROJECT IN THE DROP DOWN CHANGED, THEN PROPAGATE THOSE CHANGES TO THE EDIT FIELDS IN THE IMPORT TAB.

% data=src.Value;

fig=ancestor(src,'figure','toplevel');

% Set the project name field according to the current drop down selection
h=findobj(fig,'Type','uidropdown','Tag','SwitchProjectsDropDown');
% h.Value=getappdata(fig,'projectName');

projectName=h.Value;
setappdata(fig,'projectName',projectName)

if isempty(projectName)
	visState='off';
    setappdata(fig,'EmptyProjectName',1); % Indicates that the project name field is empty when the app was initialized.
else
    visState='on';
    setappdata(fig,'EmptyProjectName',0);
end

% Once a project name has been created, make everything visible!
projNameLabel=findobj(fig,'Type','uilabel','Tag','ProjectNameLabel');
projNameDropDown=findobj(fig,'Type','uidropdown','Tag','SwitchProjectsDropDown');
addProjButton=findobj(fig,'Type','uibutton','Tag','AddProjectButton');

h=findall(fig.Children.Children(1,1));
for i=1:length(h)
    if ismember(h(i),[projNameLabel projNameDropDown addProjButton]) % Ignore the project name textbox and label.
        h(i).Visible='on';
    else
        try
            h(i).Visible=visState;
        catch
        
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

hLog=findobj(fig,'Type','uieditfield','Tag','LogsheetPathField');
hData=findobj(fig,'Type','uieditfield','Tag','DataPathField');
hCode=findobj(fig,'Type','uieditfield','Tag','CodePathField');
hRootSave=findobj(fig,'Type','uieditfield','Tag','RootSavePlotPathField');
hNumHeaderRows=findobj(fig,'Type','uinumericeditfield','Tag','NumHeaderRowsField');
hSubjIDColHeader=findobj(fig,'Type','uieditfield','Tag','SubjIDColumnHeaderField');
hTrialIDColHeaderDataType=findobj(fig,'Type','uieditfield','Tag','DataTypeTrialIDColumnHeaderField');
hTargetTrialColHeader=findobj(fig,'Type','uieditfield','Tag','TargetTrialIDColHeaderField');
hDataTypesDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown'); % Data types drop down
hDataTypeMethodField=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField'); % Data types method number & letter edit field
hGroupsDataToLoad=findobj(fig,'Type','uipanel','Tag','SelectDataPanel'); % Panel encompassing the groups' data to load
% If the project was pre-existing
if existingProject==1
    projectNameInfo=isolateProjectNamesInfo(A,projectName); % Return the path names associated with the specified project name.
    
    % Set those path names into the figure's app data, & update the displays
    % Logsheet Path
    if isfield(projectNameInfo,'LogsheetPath')
        setappdata(fig,'logsheetPath',projectNameInfo.LogsheetPath);
        hLog.Value=getappdata(fig,'logsheetPath');
    else% Set to default
        setappdata(fig,'logsheetPath','');
        hLog.Value='Set Logsheet Path';
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
        setappdata(fig,'numHeaderRows','');
    end
    
    % Subject ID Col Header
    if isfield(projectNameInfo,'SubjIDColHeader')
        setappdata(fig,'subjIDColHeader',projectNameInfo.SubjIDColHeader);
        hSubjIDColHeader.Value=getappdata(fig,'subjIDColHeader');
    else
        hSubjIDColHeader.Value='Set Subject ID Column Header';
        setappdata(fig,'subjIDColHeader','');
    end
    
    % Trial ID Col Header
    if ~isempty(projectNameInfo)
        fldNames=fieldnames(projectNameInfo);
        for i=1:length(fldNames)
            if contains(fldNames{i},'TrialIDColHeader')
                fldName=fldNames{i};
                break;
            end
        end
    end
    if ~exist('fldName','var')
        fldName='aaa';
    end
    if isfield(projectNameInfo,fldName)
        hTrialIDColHeaderDataType.Value=projectNameInfo.(fldName);
    else
        hTrialIDColHeaderDataType.Value='Set Trial ID Column Header';
        setappdata(fig,'trialIDColHeader','');
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
                startVal=currTypeChar(alphaNumericIdx);                
                startLetter=currType{end};
                startLetter=startLetter(isletter(startLetter));
                hDataTypeMethodField.Value=currType{end};
                hDataTypesDropDown.Items={currTypeChar};
            else
                hDataTypesDropDown.Items=[hDataTypesDropDown.Items {currTypeChar}];
            end
        end
        hDataTypesDropDown.Items=sort(hDataTypesDropDown.Items);
        hDataTypesDropDown.Value=currTypeChar;
    else
        hTrialIDColHeaderDataTypeField=findobj(fig,'Type','uieditfield','Tag','DataTypeTrialIDColumnHeaderField');
        hTrialIDColHeaderDataTypeField.Visible='off';
        hDataTypesDropDown.Items={'No Data Types to Import'};
    end
    
    % Groups Data to Load
    if isfield(projectNameInfo,'GroupsDataToLoad')
        setappdata(fig,'groupsDataToLoad',projectNameInfo.GroupsDataToLoad);
        %         hGroupsDataToLoad.Value=getappdata(fig,'groupsDataToLoad');
    else
        %         hGroupsDataToLoad.Value='Set Data To Load';
        setappdata(fig,'groupsDataToLoad','');
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
    
    hTrialIDColHeaderDataTypesField=findobj(fig,'Type','uieditfield','Tag','DataTypeTrialIDColumnHeaderField');
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

if ~exist('startVal','var')
    startVal='0'; % Just to allow the search for a folder to fail when naming the buttons
    startLetter='0';
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

h=findobj(fig,'Type','uibutton','Tag','OpenSpecifyTrialsButton');
% Check if the new project's specifyTrials file exists. If not, label it
% 'Create'. If so, label it 'Open'
if exist([getappdata(fig,'codePath') 'Import_' projectName slash 'specifyTrials_Import' projectName '.m'],'file')==2 % This file exists.
    prefix='Open';
else
    prefix='Create';
end
h.Text=[prefix ' specifyTrials_Import' projectName '.m'];

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

% Change the prefix for the importMetadata button 
hButton=findobj(fig,'Type','uibutton','Tag','OpenImportMetadataButton');
if exist([getappdata(fig,'codePath') 'Import_' projectName slash startVal 'ImportMetadata' startLetter '_' projectName '.m'],'file')==2 % This file exists.
    prefix='Open';
else
    prefix='Create';
end
hButton.Text=[prefix ' importMetadata'];

% Change the prefix for the Import button
hButton=findobj(fig,'Type','uibutton','Tag','OpenImportFcnButton');
% Check if the new project's importSettings file exists. If not, label it
% 'Create'. If so, label it 'Open'
if exist([getappdata(fig,'codePath') 'Import_' projectName slash startVal 'Import' startLetter '_' projectName '.m'],'file')==2 % This file exists.
    prefix='Open';
else
    prefix='Create';
end
hButton.Text=[prefix ' Import Fcn'];

% Change the prefix for the logsheet2Struct button
hButton=findobj(fig,'Type','uibutton','Tag','OpenLogsheet2StructButton');
if exist([getappdata(fig,'codePath') 'Import_' projectName slash 'Logsheet2Struct_' projectName '.m'],'file')==2
    prefix='Open';
else
    prefix='Create';
end
hButton.Text=[prefix ' Logsheet2Struct_' projectName];
    
%% Set up the entries in the uipanel
% Each entry gets two boxes: one to load that data, one to remove it.
% At the top is the data types, one entry per data type
addDataTypeEntry2Panel(fig);

% After that, is each function group. One entry=all data for one group