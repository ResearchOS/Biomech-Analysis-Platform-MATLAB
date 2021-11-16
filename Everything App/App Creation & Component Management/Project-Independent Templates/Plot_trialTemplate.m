function [dataStruct]=Plot_trialTemplate(projInfo,subjInfo,dataStruct,args)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS
% Inputs:
% projInfo: Project-level info (struct) MANDATORY
% subjInfo: Subject-level info (struct) MANDATORY
% dataStruct: Data & info for one trial (struct) MANDATORY
% args: Other arguments, as specified here in the nargin=0 block. OPTIONAL

%% Setup before running
if nargin==0
    dataStruct.Level='T'; % Indicates trial level function
    dataStruct.Var.X='Info.Mocap.TimeVector.Method1.Value';
    dataStruct.Var.Y='Results.Mocap.BodyFixed.AngularMomentum.Method1.Value(:,1)';
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

% Save figure name: [rootFolder currSubfolder subName currDate .EXT]
currDate=char(datetime('now'));
currDate=currDate(1:6);

saveName=[projInfo.RootFolder projInfo.Subfolder subjInfo.Codename.Method1.Value currDate];

numReps=length(dataStruct.Info); % Number of reps in this trial
for repNum=1:numReps
    
    % USE THE PLOT NAME TO CHECK IF THIS TRIAL HAS BEEN PLOTTED BEFORE
%     if isfield(dataStruct.Info(repNum),'ProcessedDone') && isfield(dataStruct.Info(repNum).ProcessedDone,fName) && dataStruct.Info(repNum).ProcessedDone.(fName)==1 && projInfo.Flags.Redo==0
%         disp(['SKIPPING ' fName ' ' subjInfo.Codename.Method1.Value ' ' strTrialName]);
%     else
        disp(['RUNNING ' fName ' ' subjInfo.Codename.Method1.Value ' ' strTrialName]);
        
        startFrame=dataStruct.Info(repNum).Mocap.StartFrame.Method1.Value;
        endFrame=dataStruct.Info(repNum).Mocap.EndFrame.Method1.Value;
        
        Q=figure; % New plot
        %% TODO: Plotting code for single trial.        
        % Code here.        
        
        
        
        
        
        % Save figure name: [rootFolder currSubfolder subName currDate .EXT]
        if projInfo.Flags.SaveFIG==1
            saveas(Q,[saveName '.fig']);
        end
        if projInfo.Flags.SavePNG==1
            saveas(Q,[saveName '.png']);
        end
        if projInfo.Flags.SaveTransPNG==1
            saveas(Q,[saveName '.png']);
        end
        if projInfo.Flags.SaveSVG==1
            saveas(Q,[saveName '.svg']);
        end
        close(Q);
%     end
end