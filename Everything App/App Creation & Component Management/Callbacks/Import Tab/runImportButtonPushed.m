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
% % Target trial ID header
hTargetTrialIDFormat=findobj(fig,'Type','uieditfield','Tag','TargetTrialIDColHeaderField');
if isempty(hTargetTrialIDFormat.Value) % There are chars besides the allowable chars
    beep;
    warning(['Missing target trial ID']);
    return;
end
% Data types drop down
hDataTypesDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
if isempty(hDataTypesDropDown.Value) || isequal(hDataTypesDropDown.Value,'No Data Types to Import')
    beep;
    warning(['Missing data types to import']);
    return;
end
% specifyTrials button
hSpecifyTrialsButton=findobj(fig,'Type','uibutton','Tag','OpenSpecifyTrialsButton');
if ~isequal(hSpecifyTrialsButton.Text(1:4),'Open')
    beep;
    specTrialsNumIdx=isstrprop(hSpecifyTrialsButton.Text,'digit');
    warning(['Missing specifyTrials_Import' hSpecifyTrialsButton.Text(specTrialsNumIdx) '.m']);
    return;
end
% Data types import method
% Need to check this for every data type entered
% hDataTypesDropDownNum=findobj(fig,'Type','uieditfield','Tag','DataTypeImportMethodField');
% if isempty(hDataTypesDropDownNum.Value) || ...
%         exist([getappdata(fig,'codePath') 'Import_' getappdata(fig,'projectName') slash lower(hDataTypesDropDown.Value) 'ImportMetadata' hDataTypesDropDownNum.Value(isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m'],'file')~=2 || ...
%         exist([getappdata(fig,'codePath') 'Import_' getappdata(fig,'projectName') slash lower(hDataTypesDropDown.Value) 'Import' hDataTypesDropDownNum.Value(~isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m'],'file')~=2
%     beep;
%     if exist([getappdata(fig,'codePath') 'Import_' getappdata(fig,'projectName') slash lower(hDataTypesDropDown.Value) 'ImportMetadata' hDataTypesDropDownNum.Value(isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m'],'file')~=2
%         warning(['Missing ' lower(hDataTypesDropDown.Value) 'ImportMetadata' hDataTypesDropDownNum.Value(isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m']);
%     elseif exist([getappdata(fig,'codePath') 'Import_' getappdata(fig,'projectName') slash lower(hDataTypesDropDown.Value) 'Import' hDataTypesDropDownNum.Value(~isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m'],'file')~=2
%         warning(['Missing ' lower(hDataTypesDropDown.Value) 'Import' hDataTypesDropDownNum.Value(~isletter(hDataTypesDropDownNum.Value)) '_' getappdata(fig,'projectName') '.m']);
%     end
%     
%     return;
% end

% %% Identify which data types are being imported.
% % Identify them by which data types are present in the drop down list
% dataTypes=hDataTypesDropDown.Items;

%% FROM HERE DOWN, ASSUME THAT ALL NECESSARY CONDITIONS HAVE BEEN CHECKED & MET TO PERFORM THE IMPORT
tic;
runImport(fig); % Import and/or load/offload the data from raw data files
% runLoad(fig); % Load processed data within each individual function group
toc;