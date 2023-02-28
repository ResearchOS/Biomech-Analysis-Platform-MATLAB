function [handles]=plotComponents(currFig,isMovie,plotStructPS,subName,trialName,repNum)

%% PURPOSE: GIVEN A FIGURE HANDLE AND THE PROJECT-SPECIFIC PLOTTING STRUCT, PLOT THE COMPONENTS USING USER-DEFINED M FILES.
% Plots static plots AND movies.

figure(currFig); % Focus the current figure.
currFig.WindowState='maximized';
pause(1);

currFigPosition=get(currFig,'Position');
rect=[10 10 currFigPosition(3)-10 currFigPosition(4)-10];

if exist(plotStructPS.MFileName,'file')~=2
    error(['File does not exist! ' plotStructPS.Text]);
end

if exist('subName','var')~=1
    subName='';
end

if exist('trialName','var')~=1
    trialName='';
end

getPlotData(plotStructPS,subName,trialName); % Get all the data for the current plot.

axesList=plotStructPS.BackwardLinks_Component;

dataPath=getDataPath;

if ~isMovie
    startFrame=1;
    endFrame=1;
    iter=1;
else
    startFrame=plotStructPS.StartFrame;
    endFrame=plotStructPS.EndFrame;
    iter=plotStructPS.Interval;
end

if ischar(startFrame)
    startFrame=loadMAT(dataPath,startFrame,subName,trialName);
end
if ischar(endFrame)
    endFrame=loadMAT(dataPath,endFrame,subName,trialName);
end
assert(isa(iter,'double'));
assert(isa(startFrame,'double'));
assert(isa(endFrame,'double'));

%% Create the axes outside of the movie frame iteration, because these really shouldn't change size or position, just other properties
axStruct=cell(size(axesList));
count=0;
for i=1:length(axesList)
    ax=axesList{i};
    fullPath=getClassFilePath(ax, 'Component');
    axStruct{i}=loadJSON(fullPath);

    % Reposition the axes so things can be seen when plotting.
    pos=axStruct{i}.Position;
    if length(pos)==4
        axHandle=subplot('Position',pos);
    elseif length(pos)==3
        axHandle=subplot(pos(1),pos(2),pos(3));
    else
        error([ax ' position improperly specified']);
    end
    handles.(ax)=axHandle;
    hold on;

    if ~isfield(axStruct{i},'BackwardLinks_Component')
        continue;
    end

    axComps=axStruct{i}.BackwardLinks_Component;
    for j=1:length(axComps)
        piComp=getPITextFromPS(axComps{j});
        piCompPath=getClassFilePath(piComp,'Component');
        piCompStruct=loadJSON(piCompPath);
        if exist(piCompStruct.MFileName,'file')~=2
            error(['File does not exist! ' piCompStruct.MFileName]);
        end
        psCompPath=getClassFilePath(axComps{j},'Component');
        psCompStruct=loadJSON(psCompPath);
        count=count+1;
        runInfo{count}=getRunInfo(piCompStruct,psCompStruct);
    end
end

frameCount=0;
for frameNum=startFrame:iter:endFrame

    count=0;
    frameCount=frameCount+1;
    for i=1:length(axesList)
        ax=axesList{i};
%         fullPath=getClassFilePath(ax, 'Component');
%         axStruct=loadJSON(fullPath);
% 
%         % Reposition the axes so things can be seen when plotting.
%         pos=axStruct.Position;
%         if length(pos)==4
%             axHandle=subplot('Position',pos);
%         elseif length(pos)==3
%             axHandle=subplot(pos(1),pos(2),pos(3));
%         else
%             error([ax ' position improperly specified']);
%         end
%         handles.(ax)=axHandle;

        axes(handles.(ax));
        cla(handles.(ax));
        handles.(ax).Clipping='off';
        if isMovie
            title(handles.(ax),['Frame: ' num2str(frameNum)]);
        end

        if ~isfield(axStruct{i},'BackwardLinks_Component')
            continue;
        end

        axComps=axStruct{i}.BackwardLinks_Component;
        for j=1:length(axComps)
%             piComp=getPITextFromPS(axComps{j});
%             piCompPath=getClassFilePath(piComp,'Component');
%             piCompStruct=loadJSON(piCompPath);
%             if exist(piCompStruct.MFileName,'file')~=2
%                 error(['File does not exist! ' piCompStruct.MFileName]);
%             end
%             psCompPath=getClassFilePath(axComps{j},'Component');
%             psCompStruct=loadJSON(psCompPath);
%             getRunInfo(piCompStruct,psCompStruct);
            count=count+1;
            assignin('base','runInfo',runInfo{count});
            mfile=runInfo{count}.Fcn.PIStruct.MFileName;
            if ~isMovie
                handles.(axComps{j})=feval(mfile,subName,trialName,repNum);
            else
                handles.(axComps{j})=feval(mfile,subName,trialName,repNum,frameNum);
            end
        end

    end

    % Modify all plot components' properties
    feval(plotStructPS.MFileName, currFig, handles, subName, trialName);

    if ~isMovie
        continue;
    end

    movieVector(frameCount)=getframe(currFig,rect);

end

% Save the movie
if isMovie
    slash=filesep;
    currDate=char(datetime('now'));
    currDate=currDate(1:11);
    saveFolder=[dataPath slash 'Plots' slash plotStructPS.Text slash currDate];
    mkdir(saveFolder);
    saveName=[saveFolder slash currFig.Name];
    myWriter=VideoWriter(saveName,'MPEG-4');
    myWriter.FrameRate=20; % hard-coded for now
    open(myWriter);
    writeVideo(myWriter, movieVector);
    close(myWriter);
    close(currFig);
end

% Clean up after myself.
evalin('base','clear allPlotData runInfo;');