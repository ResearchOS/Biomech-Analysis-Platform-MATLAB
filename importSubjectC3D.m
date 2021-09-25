function projectStruct=importSubjectC3D(subName,projectStruct,sub,ProjHelper,logsheet,flags,currTrialsList,projectName)

%% PURPOSE: WRAPPER FOR THE IMPORTTRIALC3D FUNCTION, OPERATES AT THE SUBJECT LEVEL.
% Inputs:
% subName: Subject codename (char)
% projectStruct: One subject's data structure (probably only has info fields before import) (struct)
% sub: Subject number in the list of included trials (double)
% ProjHelper: Output from importSettings (struct)
% logsheet: The logsheet variable (cell)
% flags: Booleans to indicate processing settings (struct)
% currTrialsList: All trials for one subject, whether flags.Org is 0 or 1 (cell array of chars)
% projectName: importSettings suffix (char)

% Outputs:
% projectStruct: One subject's data structure (struct)

%% Import subject-level info, add to projectStruct.
subjectDataFolder=cd; % 'Subject Data' folder
if ~isfolder(subName) % If subject's data folder does not exist
    error([subName ' data folder does not exist']);
end
cd(subName); % Down into the subject's folder.
if ~(isfield(projectStruct.Subject(sub),'Info') && ~isempty(projectStruct.Subject(sub).Info))
    tempStruct=importSubjectInfo(logsheet,ProjHelper,subName,projectName,flags);
    projectStruct.Subject(sub).Info=tempStruct.Info;
    assignin('base','tempStruct',tempStruct);
    evalin('base','projectStruct.Subject(sub).Info=tempStruct.Info;');
end

for trialIter=1:length(currTrialsList)
    trialFileName=currTrialsList{trialIter}; % Current trial name to operate on.
    strTrialName=['TRIAL_' trialFileName(end-2:end)]; % 3 digits at end of the character vector are trial number
    %% TODO: INSERT SUBFUNCTIONS TO OPERATE ON ONE TRIAL AT A TIME.
    % If there's any flagged reason to load the data, OR if the data is not currently in projectStruct but it should be.
    if (flags.AddDataTypes || flags.UpdateMetadata || flags.ReloadExistingData || ~isfield(projectStruct.Subject(sub),strTrialName) ...
            || (isfield(projectStruct.Subject(sub),strTrialName) && isempty(projectStruct.Subject(sub).(strTrialName)))) || flags.Redo==1
        projectStruct.Subject(sub).(strTrialName)=importTrialC3D(projectStruct,sub,trialFileName,ProjHelper,logsheet,flags); % Import & save the trial.
    end
    
    assignin('base','strTrialName',strTrialName); % Trial name in struct
    assignin('base','tempStruct',projectStruct.Subject(sub).(strTrialName)); % Assign in to base workspace the current trial's output using a temporary variable.
    evalin('base','projectStruct.Subject(sub).(strTrialName)=tempStruct;'); % Put temporary variable in to project structure variable.    
    
end
cd(subjectDataFolder); % Goes up one level back into Subject Data folder (after all trials for that subject).