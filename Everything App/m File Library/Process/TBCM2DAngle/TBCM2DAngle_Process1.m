function [dataStruct]=TBCM2DAngle1(projInfo,subjInfo,dataStruct,args)

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
    if existField(dataStruct,'dataStruct.Results(repNum).Mocap.Cardinal.TBCMAngle.Method1.Value',repNum) && projInfo.Flags.Redo==0
        disp(['SKIPPING ' fName ' ' subjInfo.Codename.Method1.Value ' ' strTrialName]);
        continue;
    end
    
    disp(['RUNNING ' fName ' ' subjInfo.Codename.Method1.Value ' ' strTrialName]);
    
    startFrame=dataStruct.Info(repNum).Mocap.StartFrame.Method1.Value;
    endFrame=dataStruct.Info(repNum).Mocap.EndFrame.Method1.Value;
    
    %% TODO: Biomechanical operations for single trial.
    % Code here.
    tbcmVeloc=dataStruct.Results(repNum).Mocap.Cardinal.TBCMVelocity.Method1.Value(:,1:2); % Ground plane TBCM
    tLength=length(tbcmVeloc);
    tbcmAngle=NaN(tLength,1);
    vert=[0 0 1];
    if contains(dataStruct.Info(repNum).TaskType.Method1.Value,'Straight')
        if any(tbcmVeloc(:,2)>0)
            startSouth=1;
        else
            startSouth=0;
        end
    else
        if any(tbcmVeloc(startFrame:startFrame+200,2)>0)
            startSouth=1;
        else
            startSouth=0;
        end
    end
    if startSouth==1
        v2=[0 1 0]; % Walking North from South
    else
        v2=[0 -1 0]; % Walking South from North
    end
    for i=startFrame:endFrame
        x=cross([tbcmVeloc(i,:) 0],v2);
        c=sign(dot(x,vert))*norm(x);
        tbcmAngle(i)=atan2d(c,dot([tbcmVeloc(i,:) 0],v2));
    end
    
    dataStruct.Results(repNum).Mocap.Cardinal.TBCMAngle.Method1.Value=tbcmAngle;
    
    %% Assign the data to projectStruct in base workspace
    assign2base(dataStruct,strTrialName);
    
    %% Save the data to file. Assumed to enter this function from the 'MAT Data Files' folder.
    save2file(dataStruct);
end
