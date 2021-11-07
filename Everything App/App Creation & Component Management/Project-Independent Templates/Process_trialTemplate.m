function [dataStruct]=Process_trialTemplate(projInfo,subjInfo,dataStruct,records,args)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS
% Inputs:
% projInfo: Project-level info (struct) MANDATORY
% subjInfo: Subject-level info (struct) MANDATORY
% dataStruct: Data & info for one trial (struct) MANDATORY
% records: The max & min x & y axis limits for one metric MANDATORY
% args: Other arguments, as specified here in the nargin=0 block. OPTIONAL

%% Setup before running
if nargin==0
    dataStruct.Level='T'; % Indicates trial level function
    dataStruct.Args="''";
    return;
end

%% Run the code
strTrialName=['TRIAL_' dataStruct.Info(1).TrialName.Method1.Value(end-2:end)]; % Trial name/number

% Get the name of this calling function.
st=dbstack;
fName=st(1).name;

if ~isfield(dataStruct.Data,'Mocap') % Ensure the proper type of data is present.
    return;
end

numReps=length(dataStruct.Info); % Number of reps in this trial

for repNum=1:numReps
    
    % USE THE FIELD NAME & METHOD TO CHECK IF THIS TRIAL HAS BEEN PROCESSED BEFORE
    if isfield(dataStruct.Info(repNum),'ProcessedDone') && isfield(dataStruct.Info(repNum).ProcessedDone,fName) && dataStruct.Info(repNum).ProcessedDone.(fName)==1 && projInfo.Flags.Redo==0
        disp(['SKIPPING ' fName ' ' subjInfo.Codename.Method1.Value ' ' strTrialName]);
    else
        disp(['RUNNING ' fName ' ' subjInfo.Codename.Method1.Value ' ' strTrialName]);
        
        startFrame=dataStruct.Info(repNum).Mocap.StartFrame.Method1.Value;
        endFrame=dataStruct.Info(repNum).Mocap.EndFrame.Method1.Value;
        
        %% TODO: Biomechanical operations for single trial.        
        % Code here.
        
        %% Assign the data to projectStruct in base workspace
        assign2base(dataStruct,strTrialName);
        
        %% Save the data to file. Assumed to enter this function from the 'MAT Data Files' folder.
        save2file(dataStruct);
    end
end