function [projectStruct]=Process_projectTemplate(projectStruct,args)

%% PURPOSE: TEMPLATE FOR PROJECT-LEVEL PROCESSING FUNCTIONS
% Inputs:
% projectStruct: Data & info for one subject (struct) MANDATORY
% args: Other arguments OPTIONAL

%% Setup before running
if nargin==0
    projectStruct.Level='P'; % Indicates trial level function
    projectStruct.Args="''";
    return;
end

if ~isfield(projectStruct.Info,'Mocap') % Ensure the proper type of data is present.
    return;
end

% Get the name of this calling function.
st=dbstack;
fName=st(1).name;

%% Check for project-level processing already done, if applicable.
if isfield(projectStruct.Info,'ProcessedDone') && isfield(projectStruct.Info.ProcessedDone,fName) && projectStruct.Info.ProcessedDone.(fName)==1 && projectStruct.Info.Flags.Redo==0
    disp(['SKIPPING ' fName]);
    return;
end

%% IF PROJECT-LEVEL INFO WAS CHANGED.
%% Assign the project-level info to projectStruct in base workspace
projectStruct.Info.ProcessedDone.(fName)=1;
projInfoStruct.Info=projectStruct.Info;
assignin('base','tempStruct',projInfoStruct); % Send trial struct to base workspace
evalin('base','projectStruct.Info=tempStruct.Info;'); % Put trialStruct in to projectStruct variable.
save(['Metadata' projectStruct.Info.ProjectName '.mat'],projInfoStruct);

%% Trials of interest for this function
[inclStruct]=feval(['specifyTrials_' projectStruct.Info.ProjectName '_' num2str(projectStruct.Info.ProcFunc.SpecifyTrialsCount)],projectStruct.Info.LogsheetPath,projectStruct.Info.ProjectPath,projectStruct.Info.ProjectName);
[trialsOfInt,~,~]=getValidTrialNames(projectStruct.Info.LogsheetPath,projectStruct.Info.Flags.Org,inclStruct); % Trial names of interest for importing/loading.

%% Run the code
for sub=1:length(projectStruct.Subject)
    assignin('base','sub',sub); % Assign the project number in to the base workspace.
    subName=projectStruct.Subject(sub).Info.Codename;
    subNameLetters=subName(isletter(subName));
    currSubTrialsList=getCurrTrialsList(trialsOfInt.(subNameLetters)); % Gets the trial names from the current subject, whether organized by condition or subject.
    staticTrialName=projectStruct.Subject(sub).Info.Mocap.StaticLookupRefTrial;
    
    if isfield(projectStruct.Subject(sub).Info,'ProcessedDone') && isfield(projectStruct.Subject(sub).Info.ProcessedDone,fName) && projectStruct.Subject(sub).Info.ProcessedDone.(fName)==1 && projInfo.Flags.Redo==0
        disp(['SKIPPING ' fName ' SUBJECT ' projectStruct.Info.Codename]);
        return;
    end
    
    % cd down into the individual subject's data folder
    currCD=cd(projectStruct.Info.Codename);        
    
    %% IF SUBJECT-LEVEL INFO WAS CHANGED.
    %% Assign the subject-level info to projectStruct in base workspace
    projectStruct.Subject(sub).Info.ProcessedDone.(fName)=1;
    subjInfoStruct.Info=projectStruct.Subject(sub).Info;
    assignin('base','tempStruct',subjInfoStruct); % Send trial struct to base workspace
    evalin('base','projectStruct.Subject(sub).Info=tempStruct.Info;'); % Put trialStruct in to projectStruct variable.
    
    %% Save the info to file. Assumed to enter this function from the 'Subject Data' folder.
    save(['Metadata ' projectStruct.Info.Codename ' ' projInfo.ProjectName '.mat'],'subjInfoStruct','-v6');
    
    %% Iterate through trials
    numTrials=length(currTrialsList);
    for j=1:numTrials
        strTrialName=['TRIAL_' currSubTrialsList{j}(end-2:end)];
        
        numReps=length(projectStruct.(strTrialName).Info); % Number of reps in this trial
        
        for repNum=1:numReps
            
            if isfield(projectStruct.(strTrialName).Info(repNum),'ProcessedDone') && isfield(projectStruct.(strTrialName).Info(repNum).ProcessedDone,fName) && projectStruct.(strTrialName).Info(repNum).ProcessedDone.(fName)==1 && projectStruct.Info.Flags.Redo==0
                disp(['SKIPPING ' fName ' ' subjInfo.Codename ' ' strTrialName]);
            else
                disp(['RUNNING ' fName ' ' subjinfo.Codename ' ' strTrialName]);
                
                startFrame=projectStruct.(strTrialName).Info(repNum).Mocap.StartFrame.Method1.Value;
                endFrame=projectStruct.(strTrialName).Info(repNum).Mocap.EndFrame.Method1.Value;
                
                %% TODO: Biomechanical operations.
                
                % Marks when finished
                projectStruct.(strTrialName).Info(repNum).ProcessedDone.(fName)=1;
                
                %% Assign the data to projectStruct in base workspace
                assignin('base','strTrialName',strTrialName); % Send trial name to base workspace
                trialStruct=projectStruct.(strTrialName);
                assignin('base','tempStruct',trialStruct); % Send trial struct to base workspace
                evalin('base','projectStruct.Subject(sub).(strTrialName)=tempStruct;'); % Put trialStruct in to projectStruct variable.
                
                %% Save the data to file. Assumed to enter this function from the 'Subject Data' folder.
                currCD=cd('MAT Data Files'); % CD down into the mat data files folder
                saveFileName=projectStruct.Info(1).TrialName;
                save([saveFileName '.mat'],'trialStruct','-v6');
                cd(currCD); % Back into the individual subject's folder.
            end
        end
    end
    cd(currCD); % Back up out of the individual subject's data folder.
end