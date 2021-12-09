function []=runImportButtonPushed(src)

%% PURPOSE: START THE IMPORT/LOADING PROCESS AFTER THE RUN IMPORT/LOAD BUTTON ON THE IMPORT TAB IS PUSHED
% Imports bare bones data.

% data=src.UserData;
fig=ancestor(src,'figure','toplevel');

%% Check that all required fields have been completed satisfactorily
% Logsheet path
hLog=findobj(fig,'Type','uieditfield','Tag','LogsheetPathField');
if exist(hLog.Value,'file')~=2
    beep;
    warning(['Incorrect logsheet path: ' data]);
    return;
end
% Data path
hData=findobj(fig,'Type','uieditfield','Tag','DataPathField');
if exist(hData.Value,'dir')~=7
    beep;
    warning(['Incorrect data path: ' data]);
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
hDataTypesDropDownNum=findobj(fig,'Type','uieditfield','Tag','DataTypeNumField');
if isempty(hDataTypesDropDownNum.Value) || hDataTypesDropDownNum.Value<0 || mod(hDataTypesDropDownNum.Value,1)<1
    beep;
    warning(['Missing ' hDataTypesDropDown.Value ' number']);
    return;
end

%% Identify which data types are being imported.
% Identify them by which files are present

%% For each data type present, import the associated data