function [argsOut]=Process_trialTemplate(argsIn)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS
% Inputs:


%% Setup to establish processing level
if nargin==0
    argsOut='T'; % Indicates trial level function
    return;
end

%% Setup to enable loading & offloading individual groups' data. Specify the output variables' paths, similar to input arguments.
if returnPath==1
    argsOut{1}=[];
    
    return;
end

%% Run the code
strTrialName=['TRIAL_' argsOut.Info(1).TrialName.Method1.Value(end-2:end)]; % Trial name/number

% Get the name of this calling function.
st=dbstack;
fName=st(1).name;

numReps=length(argsOut.Info); % Number of reps in this trial

for repNum=1:numReps
    
    % USE THE FIELD NAME & METHOD TO CHECK IF THIS TRIAL HAS BEEN PROCESSED BEFORE
    if isfield(argsOut.Info(repNum),'ProcessedDone') && isfield(argsOut.Info(repNum).ProcessedDone,fName) && argsOut.Info(repNum).ProcessedDone.(fName)==1 && projInfo.Flags.Redo==0
        disp(['SKIPPING ' fName ' ' subjInfo.Codename.Method1.Value ' ' strTrialName]);
    else
        disp(['RUNNING ' fName ' ' subjInfo.Codename.Method1.Value ' ' strTrialName]);
        
        startFrame=argsOut.Info(repNum).Mocap.StartFrame.Method1.Value;
        endFrame=argsOut.Info(repNum).Mocap.EndFrame.Method1.Value;
        
        %% TODO: Biomechanical operations for single trial.        
        % Code here.
        
        %% Assign the data to projectStruct in base workspace
        assign2base(argsOut,strTrialName);
        
        %% Save the data to file. Assumed to enter this function from the 'MAT Data Files' folder.
        save2file(argsOut);
    end
end