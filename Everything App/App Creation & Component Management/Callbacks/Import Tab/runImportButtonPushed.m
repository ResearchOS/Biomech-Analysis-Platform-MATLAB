function [projectStruct]=runImportButtonPushed(src)

%% PURPOSE: START THE IMPORT/LOADING PROCESS AFTER THE RUN IMPORT/LOAD BUTTON ON THE IMPORT TAB IS PUSHED
% Imports bare bones data.

% data=src.UserData;
fig=ancestor(src,'figure','toplevel');

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

%% Check that all required fields have been completed satisfactorily
% Logsheet path
hLog=findobj(fig,'Type','uieditfield','Tag','LogsheetPathField');
if exist(hLog.Value,'file')~=2
    beep;
    warning(['Incorrect logsheet path: ' hLog.Value]);
    return;
end
% Data path
hData=findobj(fig,'Type','uieditfield','Tag','DataPathField');
if exist(hData.Value,'dir')~=7
    beep;
    warning(['Incorrect data path: ' hData.Value]);
    return;
end
% Code path
hCode=findobj(fig,'Type','uieditfield','Tag','CodePathField');
if exist(hCode.Value,'file')~=7
    beep;
    warning(['Incorrect code path: ' hCode.Value]);
    return;
end
% At least one data type present (necesasry?)
% # of header rows
hNumHeaderRows=findobj(fig,'Type','uinumericeditfield','Tag','NumHeaderRowsField');
if hNumHeaderRows.Value<=0 || mod(hNumHeaderRows.Value,1)>0 % 0 or negative number, or not an integer.
    beep;
    warning(['Missing number of header rows']);
    return;
end
% Subject ID column header
hSubjIDColHeader=findobj(fig,'Type','uieditfield','Tag','SubjIDColumnHeaderField');
if isempty(hSubjIDColHeader.Value)
    beep;
    warning(['Missing subject ID column header']);
    return;
end
% Trial ID column header
hTrialIDColHeader=findobj(fig,'Type','uieditfield','Tag','TrialIDColumnHeaderField');
if isempty(hTrialIDColHeader.Value)
    beep;
    warning(['Missing trial ID column header']);
    return;
end
% % Trial ID format
hTrialIDFormat=findobj(fig,'Type','uieditfield','Tag','TrialIDFormatField');
if isempty(hTrialIDFormat.Value) % There are chars besides the allowable chars
    beep;
    warning(['Missing trial ID']);
    return;
end
% % Target trial ID format
hTargetTrialIDFormat=findobj(fig,'Type','uieditfield','Tag','TargetTrialIDFormatField');
if isempty(hTargetTrialIDFormat.Value) % There are chars besides the allowable chars
    beep;
    warning(['Missing target trial ID']);
    return;
end
% Data types drop down
hDataTypesDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
if isempty(hDataTypesDropDown.Value)
    beep;
    warning(['Missing data types to import']);
    return;
end
% Data types import method
% Need to check this for every data type entered
hDataTypesDropDownNum=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField');
if isempty(hDataTypesDropDownNum.Value) || ...
        exist([getappdata(fig,'codePath') 'Import_' getappdata(fig,'projectName') slash lower(hDataTypesDropDown.Value) 'ImportMetadata' hDataTypesDropDownNum.Value(isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m'],'file')~=2 || ...
        exist([getappdata(fig,'codePath') 'Import_' getappdata(fig,'projectName') slash lower(hDataTypesDropDown.Value) 'Import' hDataTypesDropDownNum.Value(~isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m'],'file')~=2
    beep;
    if exist([getappdata(fig,'codePath') 'Import_' getappdata(fig,'projectName') slash lower(hDataTypesDropDown.Value) 'ImportMetadata' hDataTypesDropDownNum.Value(isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m'],'file')~=2
        warning(['Missing ' lower(hDataTypesDropDown.Value) 'ImportMetadata' hDataTypesDropDownNum.Value(isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m']);
    elseif exist([getappdata(fig,'codePath') 'Import_' getappdata(fig,'projectName') slash lower(hDataTypesDropDown.Value) 'Import' hDataTypesDropDownNum.Value(~isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m'],'file')~=2
        warning(['Missing ' lower(hDataTypesDropDown.Value) 'Import' hDataTypesDropDownNum.Value(~isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m']);
    end
    
    return;
end

%% Identify which data types are being imported.
% Identify them by which data types are present in the drop down list
dataTypes=hDataTypesDropDown.Items;

%% For each data type present, import the associated data
% Assumes that all data types' folders are all in the same root directory
% For convenience, for now also assumes that all trials across all data types have the
% exact same names. This should be changed in the future after
% functionality has been established

% Run specifyTrials
% Run getValidTrialNames
for i=1:length(dataTypes)
    cd([getappdata(fig,'dataPath') slash 'Subject Data' slash dataTypes{i}]); % In each data types subfolder now (from the same root folder)
    
    % Get the method number & letter for this data type's import
    
    % Iterate through all subjects, all trials
    for sub=1:nSubs
        for trialNum=1:nTrials
            % All data from one file will be packaged together into one "Trial" name, per the logsheet.
            % e.g. data from all N markers (mocap), EMG/IMU sensors (EMG/IMU), or FP's (FP) will all be returned as one variable (one struct) from the
            % import fcn (method number)
            % The method letter indicates which metadata is specified (of course, this must match what's expected by the Import fcn (method number)).
            
            % Run importMetadata function for this data type (data type & import letter specific)
            
            % Run Import Fcn for this data type (data type & import number specific)
            projectStruct.(subject).(trialName)=feval();
        end
    end
end