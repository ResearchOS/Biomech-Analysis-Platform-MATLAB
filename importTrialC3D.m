function trialStruct=importTrialC3D(projectStruct,sub,trialFileName,ProjHelper,logsheet,flags)

%% PURPOSE: IMPORT ONE TRIAL'S DATA FROM C3D FILE, & METADATA FROM...
% Inputs:
% projectStruct: The structure for the whole project. IS NOT MODIFIED IN THIS FUNCTION
% sub: The subject number in the struct (double)
% trialFileName: The current trial name (char)
% ProjHelper: The outcome of the importSettings (struct)
% logsheet: The logsheet for this project.
% flags: Struct containing Boolean flags indicating whether or not to change a setting
    % redo: Overwrite all existing data
    % addData: Add more data streams (e.g. EMG if none yet)
    % UpdateMetadata: Update all trial-level metadata

% Outputs:
% trialStruct: The data & info for the trial from the c3d file (struct)

strTrialName=['TRIAL_' trialFileName(end-2:end)];

% CD into the .mat files
if ~isfolder('MAT Data Files')
    mkdir('MAT Data Files');
end
subjectsDataFolder=cd; % Current subject's individual data folder.
cd('MAT Data Files'); % Down into .mat file folder
filesList=dir('*.mat'); % All mat files
if isempty(filesList)
    fileNames={};
else
    fileNames=cell(length(filesList),1);
end
for i=1:length(filesList)
    fileNames{i}=filesList(i).name;
end

% 0. Load the .mat file
% If .mat file exists, and is missing from the projectStruct
% OR when not missing from the projectStruct and adding new data types, or updating existing metadata, or just to reload existing data.
% AND not redoing the trial's import.
loadedTrial=0;
if (any(contains(fileNames,trialFileName)) && (~isfield(projectStruct.Subject(sub),strTrialName) || (isfield(projectStruct.Subject(sub),strTrialName) && isempty(projectStruct.Subject(sub).(strTrialName)))) ...
        || (isfield(projectStruct.Subject(sub),strTrialName) && ~isempty(projectStruct.Subject(sub).(strTrialName)) && (flags.AddDataTypes==1 || flags.UpdateMetadata==1 || flags.ReloadExistingData==1))) && flags.Redo==0
% if ((any(contains(fileNames,strTrialName)) && (~isfield(projectStruct.Subject(sub),strTrialName) || isfield(projectStruct) && )) || ...
%         (isfield(projectStruct.Subject(sub),strTrialName) && ((flags.AddDataTypes==1 || flags.UpdateMetadata==1) || flags.ReloadExistingData==1))) && flags.Redo==0 % The current trial name exists in this folder, and we want to add data (if possible), or load it.
    trialStruct=load([trialFileName '.mat']); % Load the previously imported struct.
    subStructName=fieldnames(trialStruct);
    trialStruct=trialStruct.(subStructName{1}); % Ensure continuity of naming.
    subName=trialFileName(1:find(trialFileName=='_',1,'first')-1);
    disp(['LOADING Subject ' subName ' ' trialFileName]);
    loadedTrial=1;
    if flags.ReloadExistingData==1 % Load from file and do nothing else (even to overwrite projectStruct field), but don't reimport.
        cd(subjectsDataFolder); % Returning into individual subject's data folder.
        return;
    end
end
% Criteria to add on to existing .mat file (but NOT overwrite!)
% 1. Adding new newDataTypes
if exist('trialStruct','var') && isfield(trialStruct,'Data')
    existDataTypes=fieldnames(trialStruct.Data);
    newDataTypes=ProjHelper.Info.DataTypes(~ismember(upper(ProjHelper.Info.DataTypes),upper(existDataTypes))); % New data types that aren't already in struct.
else
    newDataTypes=ProjHelper.Info.DataTypes; % Add all data types to the new trial struct.
end
if isempty(newDataTypes) && flags.Redo==0 % importSettings has no new data types to add, and not redoing import.
    strData=convertCharsToStrings(ProjHelper.Info.DataTypes);
    charData='';
    for i=1:length(strData)
        charData=[charData char(strData(i)) ' '];
    end
    charData=charData(1:end-1);
    subName=strTrialName(1:find(strTrialName=='_',1,'first')-1);
    if flags.UpdateMetadata==0 % Data already present, and not updating metadata.
        if loadedTrial==0
            disp(['SKIPPING Subject ' subName ' ' strTrialName ' - Already Contains [' charData '] Data']);
        end
        cd(subjectsDataFolder); % Back into the subject's data folder.
        return;
    elseif flags.UpdateMetadata==1 % Update metadata only.
        disp(['UPDATING METADATA ONLY Subject ' subName ' ' strTrialName ' - Already Contains [' charData '] Data']);
         % Update the marker names in each segment.
         if exist('trialStruct','var')  && isfield(trialStruct,'Data') && isfield(trialStruct.Data,'Mocap')
             markerNames=fieldnames(trialStruct.Data.Mocap.Cardinal);
             numReps=length(trialStruct.Info);
             for i=1:numReps
                 trialStruct.Info(i).Mocap.Segments=struct; % Reset the marker names for each segment.
             end
             for m=1:length(markerNames)
                 [~,~,seg]=feval(['importSettings' projectStruct.Info.ProjectName],markerNames{m});
                 segNames=fieldnames(seg);
                 for ii=1:length(segNames)
                     currSeg=segNames{ii};
                     if ~isfield(trialStruct.Info(1).Mocap.Segments,currSeg)
                         for i=1:numReps
                             trialStruct.Info(i).Mocap.Segments.(currSeg).MarkerNames{1}=upper(markerNames{m});
                         end
                     else
                         for i=1:numReps
                             nMrks=length(trialStruct.Info(i).Mocap.Segments.(currSeg).MarkerNames);
                             trialStruct.Info(i).Mocap.Segments.(currSeg).MarkerNames{nMrks+1}=upper(markerNames{m}); % Only assigning marker names, not data.
                         end
                     end
                 end
             end
         end
    end
end

%% 1-3 can be siphoned off into a subfunction to be handled in a variety of ways
% Returns:
% rowNums: The logsheet row number(s) for the current trial (vector of doubles)
% isMulti: (maybe) Flag to indicate if there are multiple trials within this file (scalar double)

% IF EXISTS (IF IS C3D FILE WITH TIMESERIES)
% startFrame: Motive frame number where good data/data of interest begins (scalar/vector of doubles)
% endFrame: Motive frame number where good data/data of interest begins (scalar/vector of doubles)
% 1. Get the logsheet row for this trial.
% Check which column contains the trial names.
[~,motiveTrialCol]=find(strcmp(logsheet(1,:),ProjHelper.Info.ColumnNames.Trial.TrialName),1,'first');
rowNums=find(contains(logsheet(:,motiveTrialCol),trialFileName)); % Trial number (file name) is just repeated in the logsheet, no separate file name.
numReps=length(rowNums); % Number of trials ("reps") under this file name.

% 2. Identify if there are multiple trials within this file.
% LOGSHEET ENTRY FOR MULTIPLE TRIALS: JUST REPLICATE THE MOTIVE TRIAL NAME
if numReps==1
    isMulti=0;
else
    isMulti=1;
end

% 3. Get the start & end frame for the trial.
[~,motiveStartFrameCol]=find(strcmp(logsheet(1,:),ProjHelper.Info.ColumnNames.Trial.MotiveInitialFrame),1,'first');
[~,motiveEndFrameCol]=find(strcmp(logsheet(1,:),ProjHelper.Info.ColumnNames.Trial.MotiveFinalFrame),1,'first');
for i=1:length(rowNums)
    startFrame(i)=logsheet{rowNums(i),motiveStartFrameCol};
    endFrame(i)=logsheet{rowNums(i),motiveEndFrameCol};
    
    if isnan(startFrame(i))
        startFrame(i)=1;
    end
    if isnan(endFrame(i))
        
    end
end

% Store the trial attributes
trialAttrs=fieldnames(ProjHelper.Info.ColumnNames.Trial);
for i=1:length(rowNums)
    for j=1:length(trialAttrs)
        headerName=ProjHelper.Info.ColumnNames.Trial.(trialAttrs{j});
        if any(strcmp(logsheet(1,:),headerName)) % Protects against missing column header names
            trialStruct.Info(i).(trialAttrs{j})=logsheet{rowNums(i),strcmp(logsheet(1,:),headerName)};
            if iscell(trialStruct.Info(i).(trialAttrs{j})) % Ensure that none of these are cells.
                trialStruct.Info(i).(trialAttrs{j})=trialStruct.Info(i).(trialAttrs{j}){1};
            end
        else
            warning([headerName ' Column Missing. Proceeding with import.']);
        end
        if isequal(headerName,'IsPerfect') && isequal(trialStruct.Info(i).IsPerfect,0) % Logsheet specified this trial as bad.
            trialStruct.Info(i).NotPerfectBecause='Import Logsheet';
        end
    end
end

if flags.UpdateMetadata==1 && isfield(trialStruct,'Data') % Finished updating metadata, and there's data already in there.
    % Save the trial with the updated metadata.
    save([trialFileName '.mat'],'trialStruct','-v6'); % Save the trial to .mat WITH V6!!
    cd(subjectsDataFolder); % Goes up one level to individual subject's data folder.
    return;
end
% IF NO C3D FILE ASSOCIATED WITH THIS TIMESERIES, JUST BE DONE AFTER IMPORTING THE METADATA FROM LOGSHEET.
% Check if there is a C3D file with this trial name.
cd(subjectsDataFolder); % Back into individual subject's data folder.
if isfolder('C3D Exports')
    cd('C3D Exports'); % Down into C3D folder.
    c3dList=dir('*.c3d');
    c3dNames=cell(length(c3dList),1);
    for i=1:length(c3dList)
        c3dNames{i}=c3dList(i).name;
    end
    if any(contains(c3dNames,trialFileName))
        isC3D=1; % If strTrialName is found as a C3D file name.
    else
        isC3D=0;
    end
else
    warning([projectStruct.Subject(sub).Info.Codename ' Has No C3D Exports Folder']);
    isC3D=0; % 0 if no C3D, 1 if so.
end
if isC3D==0 % No associated C3D file.
    return;
end
Object1=c3dserver;
openc3d(Object1,0,[trialFileName '.c3d']);
[~,subIDCol]=find(strcmp(logsheet(1,:),ProjHelper.Info.ColumnNames.Subject.Codename),1,'first');
subName=logsheet{rowNums(1),subIDCol};
if size(rowNums,1)>size(rowNums,2)
    rowNums=rowNums';
end
disp(strcat(['Now Importing ' subName ' Trial ' strTrialName ' Located in File ' char(trialFileName) '.c3d & Logsheet Row ' char(num2str(rowNums))]));
%% FP data
if any(contains(upper(newDataTypes),'FP'))
    fpsUsed=trialStruct.Info(1).FPsUsed;
    fpsUsedStr=regexprep(fpsUsed,'\s+',''); % Remove white spaces.
    expr{1}='[a-z][1-9]'; expr{2}='[1-9][a-z]'; % Can't handle a 10th (0-based #9) forceplate. Can handle either 'A1' or '1A' so long as its consistent (to avoid human errors).
    firstPosChar=fpsUsedStr(1:2:end); secondPosChar=fpsUsedStr(2:2:end);
    charExpr=repmat('[a-z]',1,length(firstPosChar));
    numExpr=repmat('[1-9]',1,length(secondPosChar));
    fpLetters=repmat('0',1,length(secondPosChar)); fpNumbers=zeros(1,length(secondPosChar));
    if ~isempty(regexpi(firstPosChar,charExpr)) && ~isempty(regexpi(secondPosChar,numExpr)) % Follows 1st format.
        charIdx=1; numIdx=2;
    elseif ~isempty(regexpi(secondPosChar,charExpr)) && ~isempty(regexpi(firstPosChar,numExpr)) % Follows 2nd format.
        charIdx=2; numIdx=1;
    end
    for i=2:2:length(fpsUsedStr) % Iterate through string list.
        currStr=fpsUsedStr(i-1:i);
        fpLetters(i/2)=currStr(charIdx); % Add letter to fp map. Which expr was used?
        fpNumbers(1,i/2)=str2double(currStr(numIdx)); % Add number to fp map. Which expr was used?
    end
    
    %digital force
    % HRESULT GetForceData ( int  nCord , int  nFP , int  nStart , int  nEnd , VARIANT *  pData )
    % nCord       [in] This is the force data that you want to retrieve.  The valid values are: 0 = FX, 1 = FY and 2= FZ
    % nFP         [in] This is the zero based value of the force platform for which the force data needs to be calculated.  This should be >=0 and <= (Number of FP – 1)
    % nStart      [in] This is the first frame for which data needs to be calculated.  This needs to be sent in terms of video frames and is a 1 based value.
    % nEnd        [in] This is the last frame for which data needs to be calculated.  This needs to be sent in terms of video frames and is a 1 based value. The value of nEnd cannot be less than the value of nStart.  If both nStart and nEnd are –1, then all the frames of data are returned.
    % pData       [out] A pointer to a Variant object.  The value returned here is the force data for all the frames.  The value stored here will be a single precision real number.  The number of frames returned are calculated as: (nEnd – nStart + 1) * AnalogToVideoRatio
    FPrateMult=Object1.GetAnalogVideoRatio;
    fpFrameRate=FPrateMult*Object1.GetVideoFrameRate; % Sample rate of the mocap system * ratio of FP:mocap sample rate.
    for i=1:numReps
        trialStruct.Info(i).FPSampleRate=fpFrameRate;
    end
    tempFFP=cell(length(fpNumbers),1); cardFFP=cell(length(fpNumbers),1);
    tempMFP=cell(length(fpNumbers),1); cardMFP=cell(length(fpNumbers),1);
    tempCOPFP=cell(length(fpNumbers),1); cardCOPFP=cell(length(fpNumbers),1);
    tempTzFP=cell(length(fpNumbers),1); cardTzFP=cell(length(fpNumbers),1);
    fpCenter=cell(length(fpNumbers),1);
    compCOPIdx=cell(length(fpNumbers),1);
    fpCount=0;
    [fpNumbers,numIdx]=sort(fpNumbers); % Rearrange fpNumbers in increasing order.
    fpLetters=fpLetters(numIdx); % Rearrange fpLetters correspondingly.
    zerofpNumbers=fpNumbers-1; % Converts from 1-based numbering to 0-based numbering.
    for zeroFpCount=zerofpNumbers % Iterate through forceplates used. Can handle numbers besides 1-N. Hopefully the c3d file indices ALWAYS match Motive FP order.
        fpCount=fpCount+1; % In case the fpNumbers isn't perfectly 1-4.
        currFPLetter=fpLetters(fpCount);
        
        if any(contains(upper(ProjHelper.Info.DataTypes),'MOCAP'))
            mocapRotMatrix2Cardinal=ProjHelper.Info.Mocap.RotMatrix2Cardinal; % For forceplate corners.
        end
        
        % Forceplate Position. In global/mocap coordinates? How does this work if mocap data not present? Works if mocap coord
        % system was set up but not used.
        counter=0;
        currCorner=zeros(3,4); % XYZ for each of 4 corners.
        for numCorner=1:4
            for xyz=1:3
                currCorner(xyz,numCorner)=(Object1.GetParameterValue(18,counter+(fpCount-1)*12));
                counter=counter+1;
            end
        end
        if any(contains(upper(ProjHelper.Info.DataTypes),'MOCAP'))
            cardCorners=mocapRotMatrix2Cardinal*currCorner;
            trialStruct.Data.FP.Cardinal.(strcat(['FP' num2str(fpCount)])).Corners(1:4,1:3)=cardCorners';
            fpCenter{fpCount}(1:3,1)=mean(cardCorners,2);
            trialStruct.Data.FP.Cardinal.(strcat(['FP' num2str(fpCount)])).Center=fpCenter{fpCount};
        else
            trialStruct.Data.FP.Local.(strcat(['FP' num2str(fpCount)])).CornersFP(1:4,1:3)=currCorner';
            fpCenter{fpCount}(1:3,1)=mean(currCorner,2);
            trialStruct.Data.FP.Local.(strcat(['FP' num2str(fpCount)])).CenterFP
        end
        
        rotMatrix2Cardinal=ProjHelper.Info.FP.(currFPLetter).RefFrame.RotMatrix2Cardinal; % For forceplate kinetic data
        h=ProjHelper.Info.FP.FPCoverThickness; % in meters.
        
        %% This is for Type 2: Fx, Fy, Fz, Mx, My, Mz (Bertec plates + Optitrack Motive setup)
        % DON'T USE GetMomentData!!! Returns garbage data.
        % Get analog data. Forces and Moments (Type 2 forceplates).
        for channelNum=1:6
            if channelNum<=3 % Forces
                tempFFP{fpCount}(channelNum,:)=cell2mat(Object1.GetAnalogDataEx(6*(fpCount-1)+channelNum-1,Object1.GetVideoFrame(0),Object1.GetVideoFrame(1),'0',0,1,'0'));
                %                             currF=tempF_FP{fpCount};
                %                             currF(currF==0)=NaN;
                %                             tempF_FP{fpCount}(channelNum,:)=currF;
            elseif channelNum>3 % Moments
                tempMFP{fpCount}(channelNum-3,:)=cell2mat(Object1.GetAnalogDataEx(6*(fpCount-1)+channelNum-1,Object1.GetVideoFrame(0),Object1.GetVideoFrame(1),'0',0,1,'0'));
                %                             currM=tempM_FP{fpCount};
                %                             currM(currM==0)=NaN;
                %                             tempM_FP{fpCount}(channelNum,:)=currM;
            end
        end
        
        FzThresh=ProjHelper.Info.FP.COPFzThreshold;
        compCOPIdx{fpCount}=false(length(tempFFP{fpCount}),1); % Initialize to all false.
        [~,k]=find(abs(tempFFP{fpCount}(3,:))>=FzThresh); % Find indices where Fz larger than threshold.
        compCOPIdx{fpCount}(k,1)=true(length(tempFFP{fpCount}(3,k)),1); % Logical vector where 1 is enough Fz to compute COP.
        largeFz=tempFFP{fpCount}(3,:); % Initialize the Fz values that will have NaN in them.
        largeFz(k)=NaN(length(k),1); % Contains only Fz values above the threshold.
        tempCOPFP{fpCount}(1,:)=(((-1*h).*tempFFP{fpCount}(1,:)-tempMFP{fpCount}(2,:))./largeFz); % COPx
        tempCOPFP{fpCount}(2,:)=(((-1*h).*tempFFP{fpCount}(2,:)+tempMFP{fpCount}(1,:))./largeFz); % COPy (multiplied by -1 for no apparent reason; now matches real world)
        tempCOPFP{fpCount}(3,:)=zeros(1,length(tempCOPFP{fpCount}));
        tempTzFP{fpCount}=zeros(2,length(tempCOPFP{fpCount}));
        tempTzFP{fpCount}(3,:)=tempMFP{fpCount}(3,:)-(tempCOPFP{fpCount}(1,:).*tempFFP{fpCount}(2,:))+(tempCOPFP{fpCount}(2,:).*tempFFP{fpCount}(1,:));
        
        cardFFP{fpCount}=rotMatrix2Cardinal*tempFFP{fpCount};
        cardMFP{fpCount}=rotMatrix2Cardinal*tempMFP{fpCount};
        cardCOPFP{fpCount}=rotMatrix2Cardinal*tempCOPFP{fpCount}+repmat(fpCenter{fpCount},1,length(cardMFP{fpCount})); % Rotates & translates.
        cardTzFP{fpCount}=rotMatrix2Cardinal*tempTzFP{fpCount}; % Free moment
        
        % Store kinetic data in local frame.
        %         trialStruct.Data.FP.(strcat(['FP' num2str(fpCount)])).ForceLocal=tempFFP{fpCount}'; % N x 3
        %         trialStruct.Data.FP.(strcat(['FP' num2str(fpCount)])).MomentLocal=tempMFP{fpCount}';
        %         trialStruct.Data.FP.(strcat(['FP' num2str(fpCount)])).COPLocal=tempCOPFP{fpCount}';
        %         trialStruct.Data.FP.(strcat(['FP' num2str(fpCount)])).TzLocal=tempTzFP{fpCount}';
        
        % Store kinetic data in cardinal frame.
        trialStruct.Data.FP.Cardinal.(strcat(['FP' num2str(fpCount)])).Force=cardFFP{fpCount}'; % N x 3
        trialStruct.Data.FP.Cardinal.(strcat(['FP' num2str(fpCount)])).Moment=cardMFP{fpCount}';
        trialStruct.Data.FP.Cardinal.(strcat(['FP' num2str(fpCount)])).COP=cardCOPFP{fpCount}';
        trialStruct.Data.FP.Cardinal.(strcat(['FP' num2str(fpCount)])).Tz=cardTzFP{fpCount}';
        
        % Specify FP start and end frames.
        for i=1:numReps
            % Forceplate info. Converts numbering from importSettings numbering system to
            % c3d 1-N numbers.
            trialStruct.Info(i).FP.(strcat(['FP' num2str(fpCount)])).RefFrame=ProjHelper.Info.FP.(currFPLetter).RefFrame;
            
            trialStruct.Info(i).FP.(strcat(['FP' num2str(fpCount)])).Position_ID_Letter=currFPLetter;
            trialStruct.Info(i).FP.(strcat(['FP' num2str(fpCount)])).AmpNum=ProjHelper.Info.FP.(currFPLetter).AmpSerial;
            trialStruct.Info(i).FP.(strcat(['FP' num2str(fpCount)])).Position=ProjHelper.Info.FP.(currFPLetter).Position;
            trialStruct.Info(i).FP.(strcat(['FP' num2str(fpCount)])).FPType=ProjHelper.Info.FP.(currFPLetter).FPType;
            trialStruct.Info(i).FP.(strcat(['FP' num2str(fpCount)])).Size=ProjHelper.Info.FP.(currFPLetter).Size;
            trialStruct.Info(i).FP.(strcat(['FP' num2str(fpCount)])).RotMatrix2Cardinal=rotMatrix2Cardinal;
            
            trialStruct.Info(i).FP.(strcat(['FP' num2str(fpCount)])).ComputeCOPFzLogical=compCOPIdx{fpCount}; % 1 when Fz over the threshold to compute COP.
            
            if isnan(startFrame(i)) % Not specified in logsheet.
                FPstartFrame(i)=1;
            else
                FPstartFrame(i)=startFrame(i)*FPrateMult-(FPrateMult-1); % Mocap and FP first datapoint are both frame 1. Mocap frame 2 occurs at FP frame (1 + FPrateMult).
            end
            if isnan(endFrame(i)) % Not specified in logsheet.
                FPendFrame(i)=length(cardCOPFP{fpCount});
            else
                FPendFrame(i)=endFrame(i)*FPrateMult;
            end
            FPlogVector=false(length(cardFFP{fpCount}),1);
            FPlogVector(FPstartFrame(i):FPendFrame(i))=true(FPendFrame(i)-FPstartFrame(i)+1,1);
            trialStruct.Info(i).FP.StartEndIndices=[FPstartFrame(i) FPendFrame(i)];
            trialStruct.Info(i).FP.LogicalVectorForIncludedFPSamples=FPlogVector;
            trialStruct.Info(i).FP.CoverThicknessH_ForCOP=h;
        end
        
    end
    
    for i=1:numReps
        tempTime=nan(length(FPlogVector),1); % Initialize the time vector
        if isfield(trialStruct.Info(i),'ZeroEventMotiveFrameNumber') && ~isempty(trialStruct.Info(i).ZeroEventMotiveFrameNumber) && ~isnan(trialStruct.Info(i).ZeroEventMotiveFrameNumber)
            zeroFrameNum=trialStruct.Info.ZeroEventMotiveFrameNumber*FPrateMult;
            tempTime(FPstartFrame(i):zeroFrameNum-1)=linspace(-(zeroFrameNum-FPstartFrame(i))/fpFrameRate,-1/fpFrameRate,zeroFrameNum-FPstartFrame(i));
            tempTime(zeroFrameNum)=0;
            tempTime(zeroFrameNum+1:FPendFrame(i))=linspace(1/fpFrameRate,(FPendFrame(i)-zeroFrameNum)/fpFrameRate,FPendFrame(i)-zeroFrameNum);
            trialStruct.Info(i).FP.TimeVectorZeroAligned=true;
        else % Not aligned to zero event. Set start of each trial to t=0
            tempTime(FPstartFrame(i):FPendFrame(i),1)=linspace(0,(FPendFrame(i)-FPstartFrame(i))/fpFrameRate,FPendFrame(i)-FPstartFrame(i)+1);
            trialStruct.Info(i).FP.TimeVectorZeroAligned=false;
        end
        trialStruct.Info(i).FP.TimeVector=tempTime;
    end
    
end

%% Mocap data
if any(contains(upper(newDataTypes),'MOCAP'))
    numMarkers=Object1.GetParameterLength(5);
    mocapFrameRate=Object1.GetVideoFrameRate; % Sample rate of the mocap system.
    
    firstFrame=Object1.GetVideoFrame(0); % c3dserver function
    lastFrame=Object1.GetVideoFrame(1); % c3dserver function
    for i=1:numReps
        trialStruct.Info(i).MocapSampleRate=mocapFrameRate;
        if firstFrame==0 % 0-based frames exported
            firstFrame=firstFrame+1;
            lastFrame=lastFrame+1;
        end
        % Captures entire trial (if frames not specified in logsheet).
        if isnan(startFrame(i))
            startFrame(i)=firstFrame;
        end
        if isnan(endFrame(i))
            endFrame(i)=lastFrame;
        end
        
        trialStruct.Info(i).Mocap.RotMatrix2Cardinal=ProjHelper.Info.Mocap.RotMatrix2Cardinal;
    end
    
    for currMarker=0:numMarkers-1  % through each marker
        
        tmp_varname=Object1.GetParameterValue(5,currMarker); % c3dserver function
        
        if ~isstring(tmp_varname) && ~ischar(tmp_varname)
            badImport=1;
            badTrialCount=badTrialCount+1;
            trialStruct.Info.Mocap.BadImportedTrials{badTrialCount,1}=subjectList{subNum,:};
            trialStruct.Info.Mocap.BadImportedTrials{badTrialCount,2}=strTrialName;
            continue; % Badly imported by C3Dserver.
        else
            badImport=0;
        end
        
        if contains(tmp_varname, "Skeleton") && ~contains(tmp_varname, "FKA") % eliminate prefixes
            colon = strfind(tmp_varname,':');
            markerName=tmp_varname(colon+1:end); % currently set for Skeleton1_, change 11 to 12 for Skeleton01_
        elseif contains(tmp_varname, "MarkerSet") && ~contains(tmp_varname, "FKA") && ~contains(tmp_varname, "MarkerSet_01_")
            colon = strfind(tmp_varname,':');
            markerName=tmp_varname(colon+1:end);
        elseif contains(tmp_varname, "MarkerSet_01_") && ~contains(tmp_varname, "FKA") % Have I seen this case?
            underscore = strfind(tmp_varname,'_');
            markerName=tmp_varname(underscore(2)+1:end);
        elseif contains(tmp_varname,'___') % Haven't seen this case.
            colon = strfind(tmp_varname,':');
            markerName=tmp_varname(colon+1:end);
        elseif contains(tmp_varname,'\') % Haven't seen this case.
            colon = strfind(tmp_varname,':');
            markerName=tmp_varname(colon+1:end);
        elseif contains(tmp_varname, "FKA") % Haven't seen this case.
            continue;
        elseif contains(tmp_varname, "Unlabeled") % Unlabeled marker "natural name" (Motive export setting toggled off)
            markerName=strrep(tmp_varname,'_1','_0');
            mCount=str2double(markerName(end-3:end)); % Goal is to make this marker name match with other Unlabeled name.
            if mCount<10
                markerName=strcat([markerName(1:end-5) '_000' num2str(mCount)]);
            elseif mCount<100
                markerName=strcat([markerName(1:end-5) '_00' num2str(mCount)]);
            elseif mCount<1000
                markerName=strcat([markerName(1:end-5) '_0' num2str(mCount)]);
            else
                markerName=strcat([markerName(1:end-5) '_' num2str(mCount)]);
            end
        elseif ~isempty(regexpi(tmp_varname,'_[0-9][0-9][0-9][0-9]')) % Unlabeled '000X' (Motive export setting toggled on)
            markerName=strcat(['Unlabeled' tmp_varname]);
        elseif contains(tmp_varname, "RigidBody")
            colonIdx=strfind(tmp_varname,':');
            markerName=tmp_varname(colonIdx+1:end);
        else
            markerName=tmp_varname;
        end
        
        markerName=upper(markerName); % Makes sure ALL marker names are capitalized.
        %                     clear tempAllXYZData;
        tempAllXYZData=zeros(3,length(cell2mat(Object1.GetPointDataEx(currMarker,0,firstFrame,lastFrame,'0'))));
        tempAllXYZData(1,:)=cell2mat(Object1.GetPointDataEx(currMarker,0,firstFrame,lastFrame,'0'));% get x (c3dserver function)
        tempAllXYZData(2,:)=cell2mat(Object1.GetPointDataEx(currMarker,1,firstFrame,lastFrame,'0'));% get y (c3dserver function)
        tempAllXYZData(3,:)=cell2mat(Object1.GetPointDataEx(currMarker,2,firstFrame,lastFrame,'0'));% get z (c3dserver function)
        tempAllXYZData(tempAllXYZData==0)=NaN; % ALL MISSING MARKER DATA WOULD TYPICALLY BE REPORTED AS [0 0 0] WILL NOW BE [NaN NaN NaN]!!!
        % Mocap data should all be stored as Nx3 matrices!!!
        trialStruct.Data.Mocap.Cardinal.(markerName)=(trialStruct.Info(1).Mocap.RotMatrix2Cardinal*tempAllXYZData)';                
        
    end
    
    for i=1:numReps
        mocapLogVector=false(length(tempAllXYZData),1);
        mocapLogVector(startFrame(i):endFrame(i))=true(endFrame(i)-startFrame(i)+1,1);
        trialStruct.Info(i).Mocap.StartEndIndices=[startFrame(i) endFrame(i)];
        trialStruct.Info(i).Mocap.LogicalVectorForIncludedMocapFrames=mocapLogVector;
        
        tempTime=nan(length(tempAllXYZData),1);
        if isfield(trialStruct.Info(i),'ZeroEventMotiveFrameNumber') && ~isempty(trialStruct.Info(i).ZeroEventMotiveFrameNumber) && ~isnan(trialStruct.Info(i).ZeroEventMotiveFrameNumber)
            zeroFrameNum=trialStruct.Info(i).ZeroEventMotiveFrameNumber;
            tempTime(startFrame(i):zeroFrameNum-1)=linspace(-(zeroFrameNum-startFrame(i))/mocapFrameRate,-1/mocapFrameRate,zeroFrameNum-startFrame(i));
            tempTime(zeroFrameNum)=0;
            tempTime(zeroFrameNum+1:endFrame(i))=linspace(1/mocapFrameRate,(endFrame(i)-zeroFrameNum)/mocapFrameRate,endFrame(i)-zeroFrameNum);
            trialStruct.Info(i).Mocap.TimeVectorZeroAligned=true;
        else % Not aligned to zero
            tempTime(startFrame(i):endFrame(i))=linspace(0,(endFrame(i)-startFrame(i))/mocapFrameRate,endFrame(i)-startFrame(i)+1);
            trialStruct.Info(i).Mocap.TimeVectorZeroAligned=false;
        end
        trialStruct.Info(i).Mocap.TimeVector=tempTime;
    end
    
    % The if statement ensures that some/any mocap data for this trial was actually imported
    if badImport==0 % Trial wasn't imported just wrongly from the c3d file. Don't know why this happens sometimes.
        %% STEP 1 B: Smooth with CSAPS,
        trialStruct=smooth_CSAPS(trialStruct);
        markerNames=fieldnames(trialStruct.Data.Mocap.Cardinal);
        
        %% Sort Markers' names into segments
        for i=1:numReps
            trialStruct.Info(i).Mocap.Segments=struct;
        end
        for m=1:length(markerNames)
            [~,~,seg]=feval(['importSettings' projectStruct.Info.ProjectName],markerNames{m});
            segNames=fieldnames(seg);
            for ii=1:length(segNames)
                currSeg=segNames{ii};
                if ~isfield(trialStruct.Info(1).Mocap.Segments,currSeg)
                    for i=1:numReps
                        trialStruct.Info(i).Mocap.Segments.(currSeg).MarkerNames{1}=upper(markerNames{m});
                    end
                else
                    for i=1:numReps
                        nMrks=length(trialStruct.Info(i).Mocap.Segments.(currSeg).MarkerNames);
                        trialStruct.Info(i).Mocap.Segments.(currSeg).MarkerNames{nMrks+1}=upper(markerNames{m}); % Only assigning marker names, not data.
                    end
                end
            end
        end
    end
end
if exist('Object1','var')
    closec3d(Object1);
end

%% Import IMU data
if any(contains(upper(newDataTypes),'IMU'))
    
end

%% Import EMG data
if any(contains(upper(newDataTypes),'EMG'))
    
end

%% Save the trial to .mat
cd(subjectsDataFolder); % Back up to subject folder (within Subject Data), out of C3D Exports.
cd('MAT Data Files'); % Down into folder to save MAT data files
save([strTrialName '.mat'],'trialStruct','-v6'); % Save the trial to .mat WITH V6!!

cd(subjectsDataFolder); % Goes up one level to individual subject's data folder.