function [dataStruct]=Plot_movieTemplate(projInfo,dataStruct,currSubTrialsList,plotFunc)

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
        clear movieVector;
        
        numReps=length(dataStruct.(strTrialName).Info); % Number of reps in this trial
        
        for repNum=1:numReps
            
            if projInfo.Flags.Plot.PlotMult==0
                Q=figure; % If plotting one trial at a time.
                Q.WindowState='maximized';
                pause(1);
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
            count=0;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % FOR EACH SUBPLOT, code should always occur in this order:
            % 1. Clear the plot (cla) and ensure clipping is off.
            % 2. Plot the data
            % 3. Set plot parameters, e.g. axis limits, axis equal, title, etc.
            % 4. Store the frame into the movieVector
            %% TODO: INSERT PLOTTING CODE
            
            for i=sF:projInfo.Flags.Plot.FrameInterval:eF % Plot in a loop all frames of interest, using the specified frame interval  
                % 0. Aggregate data
                
                
                % 1. Clear the plot (cla) and ensure clipping is off.
                h1=subplot(1,1,1); % Create a plot and assign it to a handle
                cla(h1); % Clear the figure to start with a blank slate for each frame.
                ax=gca; % Get the handle to the current axis
                ax.Clipping='off'; % Turn clipping off. This allows data to be plotted outside of the rectangle of the plot. Necessary for consistent axes
                
                % 2. Plot one frame of the data
                
                % 3. Set plotting parameters
                view([45 45]); % Azimuth & elevation. Change this to whatever view is preferred. Can even be a function of time to change viewpoint.
                hold on; % Don't overwrite the plot.
                grid on; % Turn on the grid to facilitate 3D perspective
                title(['Frame: ' num2str(i)]); % Display the frame number on the plot
                
                if i==sF % On first frame of the data, get the axis limits.
                    % Get the min & max of the current frame (or all frames if applicable) all dimensions
                    if ~isempty(segNames)
                        minSeg=squeeze(min(localSegData,[],1,'omitnan'));
                        maxSeg=squeeze(max(localSegData,[],1,'omitnan'));
                    else
                        minSeg=NaN(1,3); maxSeg=NaN(1,3);
                    end                    
                    minBest=squeeze(min(localBestData,[],1,'omitnan'));
                    maxBest=squeeze(max(localBestData,[],1,'omitnan'));
                    allMin=[min([minSeg(1) minBest(1)],[],'omitnan') min([minSeg(2) minBest(2)],[],'omitnan') min([minSeg(3) minBest(3)],[],'omitnan')];
                    allMax=[max([maxSeg(1) maxBest(1)],[],'omitnan') max([maxSeg(2) maxBest(2)],[],'omitnan') max([maxSeg(3) maxBest(3)],[],'omitnan')];
                    axis equal; % Ensure axes are equal so that spatial plots are accurate
                    if allMax(1)<centBestData(2,1)+0.1
                        allMax(1)=allMax(1)+0.1-(allMax(1)-centBestData(2,1)); % Make room for the X axis line
                    end
                    if allMax(2)<centBestData(2,2)+0.1
                        allMax(2)=allMax(2)+0.1-(allMax(2)-centBestData(2,2)); % Make room for the Y axis line
                    end
                    if allMax(3)<centBestData(2,3)+0.1
                        allMax(3)=allMax(3)+0.1-(allMax(3)-centBestData(2,3)); % Make room for the Z axis line
                    end
                    if ~all(isnan(allMin)) && ~all(isnan(allMax)) % Set the axis limits accordingly
                        xlim([allMin(1) allMax(1)]);
                        ylim([allMin(2) allMax(2)]);
                        zlim([allMin(3) allMax(3)]);
                    end
                    xL1=xlim; % Get the axes limits
                    yL1=ylim;
                    zL1=zlim;
                    xticks('manual'); % Ensure that axes limits don't auto update
                    yticks('manual');
                    zticks('manual');
                else % On later frames, set the same axes limits.
                    xlim(xL1);
                    ylim(yL1);
                    zlim(zL1);
                end
                
                % Next subplot, if any.
                
                % 4. Store the frame into the movieVector
                count=count+1;
                a=get(gcf,'Position');
                rect=[10 10 a(3)-10 a(4)-10]; % Specify the rectangle on the plot to grab.
                if projInfo.Flags.Plot.PlotMult==0
                    movieVector(count)=getframe(Q,rect); % Store one frame of a figure that's not plotting multiple trials
                else
                    movieVector(count)=getframe(Q{cond},rect); % Store one frame of a figure with multiple trials on it
                end                                
                
            end
            
            %% End editable area
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% If plotting one trial per figure, save the data to file
            if projInfo.Flags.Plot.PlotMult==0
                saveNameUse=[saveName currSubTrialsList.CondNames{cond} num2str(condCount(cond)) ' ' strTrialName];
                if any([projInfo.Flags.Plot.SaveFIG projInfo.Flags.Plot.SavePNG projInfo.Flags.Plot.SaveTransPNG projInfo.Flags.Plot.SaveSVG projInfo.Flags.Plot.Movie])
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