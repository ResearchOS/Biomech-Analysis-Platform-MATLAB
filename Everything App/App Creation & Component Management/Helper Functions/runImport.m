function []=runImport(fig)

%% PURPOSE: CALLED BY THE "RUNIMPORTBUTTONPUSHED" CALLBACK FUNCTION

hDataTypesDropDown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
dataTypes=hDataTypesDropDown.Items;

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

projectName=getappdata(fig,'projectName');

%% INDEPENDENT OF DATA TYPE
% Load the logsheet Excel file (first tab only).
logVar=load(getappdata(fig,'LogsheetMatPath'),'logVar'); % Loads in as 'logVar' variable.
% Run specifyTrials
inclStruct=feval(['specifyTrials_Import' projectName]); % Return the inclusion criteria
% Run getValidTrialNames
[trialNames]=getTrialNames(inclStruct);

%% For each data type present, import the associated data
% Assumes that all data types' folders are all in the same root directory
% For convenience, for now also assumes that all trials across all data types have the
% exact same names. This should be changed in the future after
% functionality has been established

% Iterate through subject names in trialNames variable

% Iterate through all trial names in that subject (matches Target Trial ID logsheet column)

% Find the logsheet row number of that trial name

% For that logsheet row, check which data types have trial names filled
% out. Then, read the allProjects text file for which method number &
% letter is associated with that data type, & execute that function.

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