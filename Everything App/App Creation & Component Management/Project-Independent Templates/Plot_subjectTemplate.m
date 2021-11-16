function [dataStruct]=Plot_subjectTemplate(projInfo,dataStruct,currSubTrialsList,plotFunc)

%% PURPOSE: TEMPLATE FOR TRIAL-LEVEL PROCESSING FUNCTIONS
% Inputs:
% projInfo: Project-level info (struct) MANDATORY
% dataStruct: Data & info for one subject (struct) MANDATORY
% currSubTrialsList: List of all trial names of interest for one subject (cell array of chars) MANDATORY
% args: Other arguments, as specified here in the nargin=0 block. OPTIONAL

%% Setup before running
if nargin==0
    dataStruct.Level='S'; % Indicates trial level function
    return;
end

% Get the name of this calling function.
st=dbstack;
fName=st(1).name;

%% Run the code

if ~isfield(dataStruct.Info,'Mocap') % Ensure the proper type of data is present.
    return;
end

% Save figure name: [rootFolder currSubfolder subName currDate .EXT]
currDate=char(datetime('now'));
currDate=currDate(1:6);

% Ensure that the path name is properly set to save the plot
if ~isequal(projInfo.SaveFigLoc,'\')
    projInfo.SaveFigLoc=[projInfo.SaveFigLoc '\'];
end
saveName=[projInfo.SaveFigLoc dataStruct.Info.Codename.Method1.Value ' ' currDate '\'];

if projInfo.Flags.Plot.PlotMult==1
    Q=cell(length(currSubTrialsList.Condition),1); % Initialize figure handles if plotting all trials of a condition on top of one another
end
condCount=zeros(length(currSubTrialsList.Condition),1); % Number of trials & reps that have happened in each condition.
for cond=1:length(currSubTrialsList.Condition)
    numTrials=length(currSubTrialsList.Condition(cond).TrialNames);
    if projInfo.Flags.Plot.PlotMult==1
        Q{cond}=figure; % If plotting all trials of each condition
    end
    for j=1:numTrials
        strTrialName=['TRIAL_' currSubTrialsList.Condition(cond).TrialNames{j}(end-2:end)];
        
        numReps=length(dataStruct.(strTrialName).Info); % Number of reps in this trial
        
        for repNum=1:numReps
            
            if projInfo.Flags.Plot.PlotMult==0
                Q=figure; % If plotting one trial at a time.
                condCount(cond)=condCount(cond)+1;
            end
            
            % Get the indices to plot. Can currently only do one set of indices across all subplots.
            if projInfo.DataRangeMethod~=0
                sF=dataStruct.(strTrialName).Info(repNum).Mocap.StartFrame.(['Method' num2str(projInfo.DataRangeMethod)]).Value;
                eF=dataStruct.(strTrialName).Info(repNum).Mocap.EndFrame.(['Method' num2str(projInfo.DataRangeMethod)]).Value;
            else % Plot the entirety of the trial, no matter how many reps.
                sF=1;
                eF=length(dataStruct.(strTrialName).Info(repNum).Mocap.TimeVector.Method1.Value); % Length of the entire trial.
            end
            
            disp(['PLOTTING ' fName ' ' dataStruct.Info.Codename.Method1.Value ' ' strTrialName]);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% TODO: INSERT PLOTTING CODE
            
            
            
            %% End editable area
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% If plotting one trial per figure, save the data to file
            if projInfo.Flags.Plot.PlotMult==0                
                saveNameUse=[saveName currSubTrialsList.CondNames{cond} num2str(condCount(cond)) ' ' strTrialName];
                if any([projInfo.Flags.Plot.SaveFIG projInfo.Flags.Plot.SavePNG projInfo.Flags.Plot.SaveTransPNG projInfo.Flags.Plot.SaveSVG])
                    if ~isfolder(saveName)
                        mkdir(saveName);
                    end
                    Q.WindowState='maximized';
                    pause(1);
                end
                if projInfo.Flags.Plot.SaveFIG==1
                    saveas(Q,[saveNameUse '.fig']);
                end
                if projInfo.Flags.Plot.SavePNG==1
                    saveas(Q,[saveNameUse '.png']);
                end
                if projInfo.Flags.Plot.SaveTransPNG==1
                    saveas(Q,[saveNameUse '.png']);
                end
                if projInfo.Flags.Plot.SaveSVG==1
                    saveas(Q,[saveNameUse '.svg']);
                end
                if projInfo.Flags.Plot.Movie==1
                    myWriter=VideoWriter(saveNameUse,'MPEG-4');
                    myWriter.FrameRate=round(dataStruct.(strTrialName).Info(repNum).MocapSampleRate*projInfo.Flags.Plot.PercSpeed)/projInfo.Flags.Plot.FrameInterval;
                    
                    open(myWriter);
                    writeVideo(myWriter, movieVector);
                    close(myWriter);
                end
                close(Q);
            end
        end
    end
    %% If plotting multiple trials per figure, save the data to file
    if projInfo.Flags.Plot.PlotMult==1
        if ~isfolder(saveName)
            mkdir(saveName);
        end
        saveNameUse=[saveName currSubTrialsList.ConditionNames{cond} ' All Trials'];
        if projInfo.Flags.Plot.SaveFIG==1
            saveas(Q{cond},[saveNameUse '.fig']);
        end
        if projInfo.Flags.Plot.SavePNG==1
            saveas(Q{cond},[saveNameUse '.png']);
        end
        if projInfo.Flags.Plot.SaveTransPNG==1
            saveas(Q{cond},[saveNameUse '.png']);
        end
        if projInfo.Flags.Plot.SaveSVG==1
            saveas(Q{cond},[saveNameUse '.svg']);
        end
        if projInfo.Flags.Plot.Movie==1
            myWriter=VideoWriter(saveNameUse,'MPEG-4');
            myWriter.FrameRate=round(dataStruct.(strTrialName).Info(repNum).MocapSampleRate*projInfo.Flags.Plot.PercSpeed)/projInfo.Flags.Plot.FrameInterval;
            
            open(myWriter);
            writeVideo(myWriter, movieVector);
            close(myWriter);
        end
        close(Q{cond});
    end
end