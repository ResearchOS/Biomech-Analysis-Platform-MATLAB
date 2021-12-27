function []=runImport(src)

%% PURPOSE: CALLED BY THE "RUNIMPORTBUTTONPUSHED" CALLBACK FUNCTION

fig=ancestor(src,'figure','toplevel');

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
logVar=logVar.logVar; % Convert struct to cell array
% Run specifyTrials
inclStruct=feval(['specifyTrials_Import' projectName]); % Return the inclusion criteria
% Run getValidTrialNames
[allTrialNames,logVar]=getTrialNames(inclStruct,logVar,fig,0);

%% For each data type present, import the associated data
% Assumes that all data types' folders are all in the same root directory (the data path)

targetTrialIDColHeaderField=findobj(fig,'Type','uieditfield','Tag','TargetTrialIDColHeaderField');
targetTrialIDColHeaderName=targetTrialIDColHeaderField.Value;
[~,targetTrialIDColNum]=find(strcmp(logVar(1,:),targetTrialIDColHeaderName));

subjIDColHeaderField=findobj(fig,'Type','uieditfield','Tag','SubjIDColumnHeaderField');
subjIDHeaderName=subjIDColHeaderField.Value;
[~,subjIDColNum]=find(strcmp(logVar(1,:),subjIDHeaderName));

% Iterate through subject names in trialNames variable
subNames=fieldnames(allTrialNames);
for subNum=1:length(subNames)
        
    subName=subNames{subNum};
    trialNames=allTrialNames.(subName);
    
    % Iterate through all trial names in that subject (matches Target Trial ID logsheet column)
    for trialNum=1:length(trialNames)
        
        trialName=trialNames{trialNum};
        
        % Find the logsheet row number of that trial name
%         matchIdxs=find(ismember(trialNames,trialName)); % The trial name indices matching the current trial name
        
        subRowIdx=strcmp(logVar(:,subjIDColNum),subName);
        rowNums=find(strcmp(logVar(subRowIdx,targetTrialIDColNum),trialName))+find(subRowIdx==1,1,'first')-1; % The row numbers with that name.
        
        for repNum=1:length(rowNums)
            
            rowNum=rowNums(repNum);
            
            
            
            projectStruct.(subName).(trialName).Data.(dataType)=dataTypeStruct;
            
        end
        
%         rowNum=rowNums(matchIdxs); % Isolate the proper row number
        
        % For that logsheet row, check which data types have trial names filled
        % out. Then, read the allProjects text file for which method number &
        % letter is associated with that data type, & execute that function.
        
    end    
    
end

%% NOTE: DON'T FORGET TO TAKE INTO ACCOUNT THE CHECKBOXES

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