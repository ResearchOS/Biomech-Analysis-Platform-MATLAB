function []=logsheetPathFieldValueChanged(src,event)

%% PURPOSE: UPDATE THE LOGSHEET PATH FIELD VALUE, AND SAVE A COPY OF THE XLSX FILE TO MAT FILE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
projectName=getappdata(fig,'projectName');

logsheetPath=handles.Import.logsheetPathField.Value;

if isempty(logsheetPath) || isequal(logsheetPath,'Logsheet Path (ends in .xlsx)')
    setappdata(fig,'logsheetPath','');
    return;
end

if exist(logsheetPath,'file')~=2
    warning(['Incorrect logsheet path: ' logsheetPath]);
    return;
end

if ispc==1 % On PC
    slash='\';
elseif ismac==1 % On Mac
    slash='/';
end

handles.Import.logsheetPathField.Value=logsheetPath;

setappdata(fig,'logsheetPath',logsheetPath);

macAddress=getComputerID();
% projectSettingsMATPath=[getappdata(fig,'codePath') 'Settings_' projectName '.mat'];

% Save the data path to the project-specific settings
settingsMATPath=getappdata(fig,'settingsMATPath'); % Get the project-independent MAT file path
settingsStruct=load(settingsMATPath,projectName);
settingsStruct=settingsStruct.(projectName);

projectSettingsMATPath=settingsStruct.(macAddress).projectSettingsMATPath; % Isolate the path to the project settings MAT file.

% 1. Load the project settings structure MAT file. It should always exist
% by this point!
if exist(projectSettingsMATPath,'file')~=2
    beep;
    disp(['Missing the settings MAT file for project: ' projectName]);
    disp(['Should be located at: ' projectSettingsMATPath]);    
    return;
end

NonFcnSettingsStruct=load(projectSettingsMATPath,'NonFcnSettingsStruct'); % Load the non-fcn settings struct from the project settings MAT file
NonFcnSettingsStruct=NonFcnSettingsStruct.NonFcnSettingsStruct;

NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPath=logsheetPath; % Store the computer-specific logsheet path to the struct

% Convert the logsheet to .mat file format.
[logsheetFolder,name,ext]=fileparts(logsheetPath);
logsheetPathMAT=[logsheetFolder slash name '.mat'];

% IN THE FUTURE, DO OTHER EXTENSIONS TOO (CSV, OTHERS?)
if contains(ext,'xls')
    [~,~,logsheetVar]=xlsread(logsheetPath,1);
end

% If numHeaderRows>=0 and subject ID codename column header and target trial ID column headers are found in the first row of the logsheet, 
% then ensure that every entry in the column is a valid MATLAB variable name before saving to .mat file format.
subjIDColHeader=NonFcnSettingsStruct.Import.SubjectIDColHeader;
targetTrialIDColHeader=NonFcnSettingsStruct.Import.TargetTrialIDColHeader;
numHeaderRows=NonFcnSettingsStruct.Import.NumHeaderRows;

if all(ismember({subjIDColHeader,targetTrialIDColHeader},logsheetVar(1,:))) && numHeaderRows>=0 % All logsheet-related fields have been properly filled out, except data type-specific ones (because they're used for read only)
    subjCodenames=logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),subjIDColHeader));
    targetTrialIDs=logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),targetTrialIDColHeader));
    for i=1:length(subjCodenames)
        if ~isvarname(subjCodenames{i}) && ~isempty(subjCodenames{i})
            subjCodenames{i}=genvarname(subjCodenames{i});            
        end
        if ~isvarname(targetTrialIDs{i}) && ~isempty(targetTrialIDs{i})
            targetTrialIDs{i}=genvarname(targetTrialIDs{i});
        end
    end
    logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),subjIDColHeader))=subjCodenames;
    logsheetVar(numHeaderRows+1:end,ismember(logsheetVar(1,:),targetTrialIDColHeader))=targetTrialIDs;
end

save(logsheetPathMAT,'logsheetVar','-v6'); % Save the MAT file version of the logsheet.

NonFcnSettingsStruct.Import.Paths.(macAddress).LogsheetPathMAT=logsheetPathMAT;

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append'); % Save the struct back to file.