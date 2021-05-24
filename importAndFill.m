% Generalized importAndFill
% Automated set-up of importStruct using C3D and Noraxon files for
% the project folder indicated by projectPath. The processing logsheet
% is used to populate Info fields at the Subject and Trial levels.
% See File Structure and importStruct for more.
% All c3d files are imported, gap-filled, smoothed by CSAPS and sorted
% into segments. Noraxon files are then imported, binned and normalized.
% Utilizes project-specific importSettings function for subInfoMap and
% trialInfoMap. See Map and Appending Project Suffix for more.
% Uses c3dserver object to open and import C3D file;
% see C3D Server Usage & Typical C3DServer Object for more.
% ‘FKA’, ‘Unlabeled’, and ‘RigidBody’ markers are ignored.
% C3D files cannot have spaces due to c3dserver restrictions.
%
% Inputs:
% 	projectPath – Location of project folder.
%	projectName – suffix to be used for project-specific functions of this project
% Outputs:
% 	importStruct - outputted Project Structure.
% 	batchRaw – raw version of Excel logsheet. Should only be used during testing and debugging

%
% Update Log
% 3/27/18 MP - Initially written from importAndFillVolleyball
% 4/3/18 MP - General bug squashing
% 4/5/18 MP - Passed ShoulderArthro and Volleyball testing, Documentation
% 4/19/18 MP - Updated documentation
% 5/15/18 AZ - line 356 & 433 added exception of "time" channel being exported by noraxon...
% 6/11/18 AZ- in ignoring FKA.. added marker name needs both markerset and NO FKA or skeleton and NO FKA (around line 138)
% 6/11/18 AZ- if you import EMG only, added lines around 335 to deal with importStruct.Subject(#) not existing yet... added other "keyframe" info to presizee projStruct.Subject
% 6/13/18 AZ - if you are using vball c3ds, setting trial name needed to be fixed around line105
% 6/14/18 AZ - pad mkr data with first measured value instead of mean value ~lines 190&218
% 6/15/18 AZ - deleted extraneous section within the CSAPs loop! ugh
% 6/15/18 AZ - fixed gap filling portion with small errors
% 7/31/18 AZ fixed zero detection... need z marker level *100 rounded down to ==0 Line 175
% 8/02/18 AZ removed extremely large/small imported positions >=100 or <=.0001 meters around line 170
% 8/25/18 AZ added cell2mat on line 86 ... removed cell2mat later in file
% 8/25/18 AZ added exception for markernames including "____:C7"  and "/:C7" for ex.
% 8/27/18 AZ added exception for Arthro subjects collected after Noraxon was updated
% 8/28/18 AZ UNTESTED fixed Noraxon TrialName import
% 8/30/18 AZ Added force data read-in from c3d for pitching project
% 8/30/18 AZ fixed EMG filtering code... removed faulty zero offset code Noraxon EMG data doesn't need this
% 12/12/18 AZ added emg delay shift... don't need it in parse code now
% 10/13/20 MT if data is cropped (e.g. start/end frame numbers specified) the entire file's raw data is maintained and has logical vectors indicating which frames are used.

%% CURRENTLY CANNOT IMPORT CLUSTERS! SKELETON MARKERS AND UNLABELED MARKERS ONLY!

% function [importStruct,batchRaw] = importAndFill(projectPath,projectName)
projectName='Spr21TWWBiomechanics';
% projectPath='C:\Users\zafer\Documents\MATLAB\GitRepos\TurnTest'; % Dell laptop
projectPath='C:\Users\Mitchell\Desktop\Matlab Code\GitRepos\Spr21-TWW-Biomechanics'; % For Mitchell's desktop
currFolder=fileparts(which(mfilename)); % Works if the importAndFill.m file is "Ran".
addpath(genpath(currFolder)); % Add General Processing subfolders to path (for C3D server)
addpath(projectPath);
%% Check if adding to existing structure.
isAdd=input('0 to create new variable, 1 to load existing data from structure, or 2 to use existing variable in workspace: '); % Asks if this is a new structure being created, or an existing one being added to.
if isequal(isAdd,1) % Can add whole subjects (and individual trials to existing subjects?)
    isSure=0;
    while isSure~=1
        [structFileName,structPath]=uigetfile('*.mat'); % GUI file browser to select the .mat file being added to.
%         cprintf('Errors',structFileName);        
        disp(structFileName);
        isSure=input('Is that Correct? 1 if yes: '); % To triple check that the proper file was selected.
    end
    importStruct=load([structPath structFileName]);
    % Need to correct the struct name here.
    structName=fieldnames(importStruct); % Isolate the name of the project.
    hyphenIdx=strfind(structName{1},'_'); % All structs must follow naming convention of "projectName_pipelineComponent" (e.g. SoundBalance_importStruct).
    projectName=structName{1}(1:hyphenIdx-1); % The hypen is important!!
    importStruct=importStruct.(structName{1}); % Rename project-specific structure name to generic cleanTrialsStruct.
elseif isequal(isAdd,2) % Indicates using an existing struct in workspace.
%     NOTE: WITH THIS CODE SECTION HERE, THE PROJECTSTRUCT VAR IS THE ONLY ONE THAT CAN HAVE '_' IN ITS NAME
% NEED TO WORK ON THIS SECTION
    a=who;
    if any(contains(a,'_')) || any(contains(a,'importStruct')) % Struct variable was manually loaded in
        if any(contains(a,'importStruct'))
                     
        elseif any(contains(a,'_'))
            importStruct=a(contains(a,'_')); importStruct=importStruct{1};
            importStruct=eval(importStruct);
        end        
    end
else
   isAdd=0; % Indicates creating new structure 
   clear importStruct;
end

%% Load logsheet
[logsheetName, logsheetPath] = uigetfile('*.xlsx','Pick a logsheet'); % Specify logsheet path.
importStruct.Info.LogsheetPath=[(logsheetPath) (logsheetName)];
[~,~,batchRaw]=xlsread([(logsheetPath) (logsheetName)],1); % batchRaw = name of Excel file.

%% Run from here down to not have to reload logsheet when testing.
clearvars -except projectName projectPath currFolder logsheetName logsheetPath batchRaw importStruct isAdd;
clearvars -global segMarkerCount;
global segMarkerCount;
%% Load info
cd (projectPath);
[ProjHelper,dataTypes]=feval(['importSettings' projectName]); % Returns the column names from the specified logsheet.
importStruct.Info.ImportSettingsPath=[projectPath '\importSettings' projectName];
importStruct.Info.ProjectName=projectName; % Store the project name.
dateTimeStr={'Created','LastModified','LastModified'}; % If isAdd=0, or if isAdd=1, use first or second option.
% LastStepProcessed is meant to help when reprocessing existing data, including data from later steps. But is this actually helpful?
importStruct.Info.LastStepProcessed='Import'; % Indicates that, no matter which data is actually present/leftover from later steps, importing is the last step done.
importStruct.Info.(['DateTime_' dateTimeStr{isAdd+1} 'Import'])=datestr(datetime('now'));
importStruct.Info.CollectionSite=ProjHelper.Info.DataCollectionSite;
importStruct.Info.SubjectNames=ProjHelper.Info.SubjectList;
subjectList=importStruct.Info.SubjectNames;
colNames=ProjHelper.Info.ColumnNames;
% Pull the 3 constant/hardcoded columns used for flow control
[~,subIDCol]=find(strcmp(batchRaw(1,:),colNames.Subject.Codename),1);
[~,taskTypeCol]=find(strcmp(batchRaw(1,:),colNames.Trial.TaskType));
importStruct.Info.TaskTypeColNumber=taskTypeCol; % Stores the task type column number for use with the phase definitions.
importStruct.Info.PhaseDefsThresholdTaskName=ProjHelper.Info.PhaseDefsThresholdTaskName; % This is the task to use for developing phases of the turn.
importStruct.Info.TaskOfIntName=ProjHelper.Info.TaskOfIntName; % This is the turning while walking task.
importStruct.Info.StaticCalTaskName=ProjHelper.Info.StaticCalTaskName; % Task used to store person's height, weight, & head model data.
importStruct.Info.DynamicCalTaskName=ProjHelper.Info.DynamicCalTaskName; % Generates 3D joint centers & axes.
importStruct.Info.DynamicCalJoints=ProjHelper.Info.DynamicCalJoints; % Joints to create in dynamic calibration.
importStruct.Info.DynamicCalJointsSegments=ProjHelper.Info.DynamicCalJointsSegments; % Segment names used to generate the dynamic calibration joints.
importStruct.Info.StaticCalJoints=ProjHelper.Info.StaticCalJoints; % Joints to create in static calibration.
importStruct.Info.StaticCalJointsSegments=ProjHelper.Info.StaticCalJointsSegments; % Segment names used to generate the static calibration joints.
importStruct.Info.MaxTBCMHoldDur=ProjHelper.Info.MaxHoldDur; % Maximum NUMBER OF FRAMES to hold the TBCM value for.
importStruct.Info.Cardinal.RefFrame=ProjHelper.Info.Cardinal; % Cardinal reference frame.
if any(contains(dataTypes,'MOCAP'))
    importStruct.Info.Mocap.OriginalRefFrame=ProjHelper.Info.Mocap.RefFrame;
end
if any(contains(dataTypes,'MOCAP')) || any(contains(dataTypes,'FP')) % If using Motive software at all.
    [~,motiveTrialCol]=find(strcmp(batchRaw(1,:),colNames.Trial.TrialName),1);
    importStruct.Info.MotiveTrialCol=motiveTrialCol;
    [~,motiveFileCol]=find(strcmp(batchRaw(1,:),colNames.Trial.FileName),1);
    importStruct.Info.MotiveFileCol=motiveFileCol;
end
if any(contains(dataTypes,'FP'))
    % Discern FP mapping from logsheet.
    % Letters = real-world forceplate position.
    % Numbers = Motive FP order number.
    % Key: A=Large portable, B=NW in-ground, C=SW in-ground, D=NE in-ground, E=SE in-ground
    % e.g. 'A1 B2 C3 D4 E5' OR 'A2 B4 C3 D1 E5' etc. as appropriate.
    % 1. Identify logsheet column name that specifies Motive order number to real-world forceplate position.
    % 2. Isolate (in order of attached numbers) the letters present in the logsheet.
    [~,fpUsedCol]=find(strcmp(batchRaw(1,:),colNames.Subject.FPsUsed),1);
    importStruct.Info.FP.COPFzThreshold=ProjHelper.Info.FP.COPFzThreshold;        
end
if any(contains(dataTypes,'IMU')) || any(contains(dataTypes,'EMG')) % If IMU or EMG data, search for Noraxon trial info.
    [~,noraxonTrialCol]=find(strcmp(batchRaw(1,:),'Noraxon Trial Name'),1);
    importStruct.Info.NoraxonFileCol=noraxonTrialCol;
end

%% Change current directory and list subjects
cd (projectPath);
cd 'Subject Data';
importStruct.Info.SubjectDataLocation=cd;

if size(subjectList,1)== 0 || isempty(subIDCol)
    error('No subjects specified');
end
NumofSubs=length(subjectList);
% Handle MarkerData
for subNum=1:NumofSubs % Regardless of whether adding existing struct, do at least some processing for all subjects (to be able to add on a per-trial basis).    
    
    if any(contains(dataTypes,'MOCAP'))
        importStruct.Info.Mocap.SegmentList=sort(ProjHelper.Info.Mocap.SegmentList); % Already sorted alphabetically, but can't hurt to do it twice.
        % NOW SUBJECT-SPECIFIC, because different auxiliary markers for different subjects.
        importStruct.Subject(subNum).Info.Mocap.TrackingMarkerList=ProjHelper.Info.Mocap.Subject(subNum).TrackingMarkerList; % Tracking markers, kept on throughout the entire experiment.
        importStruct.Info.Mocap.AnatMarkerList=ProjHelper.Info.Mocap.AnatMarkerList; % Anatomical/calibration marker names, removed after static/dynamic trials.
        importStruct.Info.Mocap.BOSMarkerNames=ProjHelper.Info.Mocap.BOSMarkerNames; % Markers that could comprise the BOS.
        importStruct.Info.Mocap.VirtualMarkerNames=ProjHelper.Info.Mocap.VirtualMarkerNames;
        importStruct.Info.Mocap.RigidBodyMarkerNames=ProjHelper.Info.Mocap.RigidBodyMarkerNames;
        importStruct.Info.Mocap.RigidBodyNames=ProjHelper.Info.Mocap.RigidBodyNames;
    end
    subRow =find(strcmp(batchRaw(:,subIDCol),strtrim(subjectList(subNum,:))),1); %find first row for subject
    if isempty(subRow)
        warning(strcat(['Subject ' strtrim(subjectList{subNum,:}) ' Row not found']));
    end
    
    if any(contains(dataTypes,'FP')) % Identify which forceplates were used for this subject.
        fpsUsed=batchRaw(subRow,fpUsedCol);
        fpsUsedStr=regexprep(fpsUsed{:},'\s+',''); % Remove white spaces.
        expr{1}='[a-z][1-9]'; expr{2}='[1-9][a-z]'; % Can't handle a 10th (0-based #9) forceplate. Can handle either 'A1' or '1A' so long as its consistent (to avoid errors).
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
    end
    
    % Store subject info.
    subAttrs=fieldnames(colNames.Subject);
    for i=1:length(subAttrs) % Populate subject-level info fields.
        headerName=colNames.Subject.(subAttrs{i});
        importStruct.Subject(subNum).Info.(subAttrs{i})=batchRaw(subRow,strcmp(batchRaw(1,:),headerName));
    end
        
    if any(contains(dataTypes,'MOCAP')) % Stores the COM % distance down long. axis from proximal segment endpoint (in segment alphabetical order).
        if isfield(importStruct.Subject(subNum).Info,'MocapSampleRate') % && isAdd Do I need this?
            % Checks that this subject hasn't already done the moments of inertia (De Leva).
        else
            % Moments of inertia are incomplete initially! Don't want to overwrite.
            segCount=0;
            for i=1:length(importStruct.Info.Mocap.SegmentList)-2 % Iterate through each segment. Ignore "Unassigned" and "Unlabeled"
                if ~isequal(importStruct.Info.Mocap.SegmentList{i},'UNLABELED') && ~isequal(importStruct.Info.Mocap.SegmentList{i},'UNASSIGNED')
                    segName=importStruct.Info.Mocap.SegmentList{i}; segCount=segCount+1;
                    if isequal(importStruct.Subject(subNum).Info.Gender{1},'m')
                        importStruct.Subject(subNum).Info.Mocap.Segments.(segName).COMPercLoc=ProjHelper.Info.Mocap.Male.COMPercLoc(segCount);
                        importStruct.Subject(subNum).Info.Mocap.Segments.(segName).SegmentPercWeight=ProjHelper.Info.Mocap.Male.SegWeights(segCount); % Percent of body mass for each segment.
                        importStruct.Subject(subNum).Info.Mocap.Segments.(segName).MomentOfInertia.X=ProjHelper.Info.Mocap.Male.MomentofInertia.X(segCount);
                        importStruct.Subject(subNum).Info.Mocap.Segments.(segName).MomentOfInertia.Y=ProjHelper.Info.Mocap.Male.MomentofInertia.Y(segCount);
                        importStruct.Subject(subNum).Info.Mocap.Segments.(segName).MomentOfInertia.Z=ProjHelper.Info.Mocap.Male.MomentofInertia.Z(segCount);
                    elseif isequal(importStruct.Subject(subNum).Info.Gender{1},'f')
                        importStruct.Subject(subNum).Info.Mocap.Segments.(segName).COMPercLoc=ProjHelper.Info.Mocap.Female.COMPercLoc(segCount);
                        importStruct.Subject(subNum).Info.Mocap.Segments.(segName).SegmentPercWeight=ProjHelper.Info.Mocap.Female.SegWeights(segCount);
                        importStruct.Subject(subNum).Info.Mocap.Segments.(segName).MomentOfInertia.X=ProjHelper.Info.Mocap.Female.MomentofInertia.X(segCount);
                        importStruct.Subject(subNum).Info.Mocap.Segments.(segName).MomentOfInertia.Y=ProjHelper.Info.Mocap.Female.MomentofInertia.Y(segCount);
                        importStruct.Subject(subNum).Info.Mocap.Segments.(segName).MomentOfInertia.Z=ProjHelper.Info.Mocap.Female.MomentofInertia.Z(segCount);
                    end
                end
            end
        end
    end
    
    c3dLocation=fullfile((char(strtrim(subjectList(subNum,:)))),'C3D Exports');
    % If no C3D Exports folder, skip this subject
    if (exist(c3dLocation,'file')==0)
        error(strcat(['No C3D Exports folder exists for subject ' subjectList{subNum,:}]));
%         continue;
    end
    cd (c3dLocation);    
    filesList= ls('*.c3d'); % Find a list of all files for that subject.
    if size(filesList)==0
        warning(strcat(['No trials found for subject ' strtrim(subjectList{subNum,:})]));
        %         error('No trials found');
    end
    % Get list of all trial rows for one subject, until the next subject (or empty line in that column)
    % If a file has multiple trials, it should occupy multiple rows in the logsheet (one for each trial)
    rowCount=0; clear subTrialRows;
    for i=1:size(batchRaw,1)
        if isequal(subjectList{subNum,:},batchRaw{i,subIDCol}) % Only look in this subject's rows.
            rowCount=rowCount+1;
            subTrialRows(rowCount)=i; % Should always be in ascending order.
        elseif isnan(batchRaw{i,subIDCol})
            break; % This stops checking if an empty subject row is found (so as to avoid checking 1 million rows).
        end
    end
    numberOfTrials=0;
    logsheetFilenames=strings(subTrialRows(end),1); % Index here corresponds to logsheet row.
    logsheetTrialnames=strings(subTrialRows(end),1);
    logsheetSubjectnames=strings(subTrialRows(end),1);
    for i=subTrialRows % Iterate through only this subject's rows. Allows for skipped and out of order trial numbers.
        % Duplicate filenames indicate that there are duplicate rows for
        % that file, which means that there are multiple trials within that
        % file.
        logsheetTrialnames(i)=string(batchRaw{i,motiveTrialCol}); % Index number corresponds to logsheet row number.
        logsheetFilenames(i)=string(batchRaw{i,motiveFileCol});
        logsheetSubjectnames(i)=string(batchRaw{i,subIDCol}); % Should all be the one subject name.
        if ~isempty(logsheetFilenames{i}) && ~isempty(logsheetTrialnames{i}) && ~isempty(logsheetSubjectnames{i})
            numberOfTrials=numberOfTrials+1; % Should match length(subTrialRows)
        end
    end
    
    %% NEEDS TO MANAGE FRAME NUMBERS FOR MULTIPLE TRIALS IN ONE FILE. IF ONE FILE=ONE TRIAL && NO FRAME NUMBERS SPECIFIED, IMPORT ENTIRE FILE.
    badTrialCount=0;
    trialNums=zeros(length(logsheetTrialnames),1);
    for i=subTrialRows
        currTrialName=char(logsheetTrialnames(i));
        if length(currTrialName) >= 4 && ~isempty(regexpi(currTrialName(end-2:end),'[0-9][0-9][0-9]')) && isequal(currTrialName(end-3),'_')
            trialNums(i)=str2double(currTrialName(end-2:end)); % This is the trial number from the logsheet row.
        else
            error(strcat(['Error: Trial ' currTrialName ' Is Not Numbered With Three Digits.']));
        end
    end
    for trialRow=subTrialRows
        % If multiple trials within one file, subsequent file numbers in folder will not
        % match up with trial numbers.  
        trialNum=trialNums(trialRow); % The trial number as represented in the logsheet.
        trialFileName = logsheetFilenames(trialRow); % File number for this trial. May be duplicate if file contains multiple trials.
        trialName=logsheetTrialnames(trialRow);
        assert(isequal(str2double(trialName{1}(end-2:end)),trialNum)); % Checking that the trial number matches that found in the logsheet.                
        % CHECK FOR DUPLICATES OF THIS FILENAME IN THE LOGSHEET.
        % IF DUPLICATES, SHOULD NOT PROCEED WITHOUT FRAME NUMBERS IN LOGSHEET ROW.
        % IF NO DUPLICATES, CAN PROCEED WITH OR WITHOUT FRAME NUMBERS IN LOGSHEET ROW.
        isMulti=sum(strcmp(logsheetFilenames,trialFileName))>1; % If 1, the file contains multiple trials.
        startFrame=cell2mat(batchRaw(trialRow,strcmp(batchRaw(1,:),colNames.Trial.MotiveInitialFrame)));
        endFrame=cell2mat(batchRaw(trialRow,strcmp(batchRaw(1,:),colNames.Trial.MotiveFinalFrame)));
        % Trial number (as labeled in the importStruct) may not correlate
        % to file number of that trial.
        if trialNum >= 100 % Current trial.
            strTrialName=strcat(['TRIAL_' num2str(trialNum)]); % e.g. '043'            
        elseif trialNum >= 10
            strTrialName=strcat(['TRIAL_0' num2str(trialNum)]); % e.g. '043'            
        else
            strTrialName=strcat(['TRIAL_00' num2str(trialNum)]); % e.g. '043'            
        end        
        if trialNum>=99 % Next trial.
            strTrialNameNext=strcat(['TRIAL_' num2str(trialNum+1)]); % e.g. '043'
        elseif trialNum>=9
            strTrialNameNext=strcat(['TRIAL_0' num2str(trialNum+1)]); % e.g. '043'
        else
            strTrialNameNext=strcat(['TRIAL_00' num2str(trialNum+1)]); % e.g. '043'
        end
        if isfield(importStruct.Subject(subNum),strTrialName) && isfield(importStruct.Subject(subNum).(strTrialName),'Info') && isfield(importStruct.Subject(subNum).(strTrialName).Info,'ImportProcessed') % If the next trial hasn't been done, do this trial again just to be sure it's complete.
            % Trial already done. Skip this trial.
            disp(strcat(['ALREADY DONE, SKIPPING: ' char(subjectList{subNum,:}) ' Trial ' char(num2str(trialNum)) ' Located in File ' char(trialFileName) '.c3d & Logsheet Row ' char(num2str(trialRow))]));
        else
            disp(strcat(['Now Serving ' char(subjectList{subNum,:}) ' Trial ' char(num2str(trialNum)) ' Located in File ' char(trialFileName) '.c3d & Logsheet Row ' char(num2str(trialRow))]));
            if isMulti && (isnan(startFrame) || isnan(endFrame))
                error(strcat(['Subject ' char(subjectList(subNum)) ' ' strTrialName ' Missing Start and/or End Frames from Motive in Logsheet']));
            end
            filePath = fullfile(pwd,trialFileName);
            
            % Store trial info.
            trialAttrs=fieldnames(colNames.Trial);
            for i=1:length(trialAttrs) % Populate trial-level info fields.
                headerName=colNames.Trial.(trialAttrs{i});
                importStruct.Subject(subNum).(strTrialName).Info.(trialAttrs{i})=batchRaw(trialRow,strcmp(batchRaw(1,:),headerName));
            end
            
            % Add 'NotPerfectBecause' field to info, to document why/when a trial was removed.
            if importStruct.Subject(subNum).(strTrialName).Info.IsPerfect{1}==0
                importStruct.Subject(subNum).(strTrialName).Info.NotPerfectBecause{1}='Logsheet';
            elseif importStruct.Subject(subNum).(strTrialName).Info.IsPerfect{1}==1
                importStruct.Subject(subNum).(strTrialName).Info.NotPerfectBecause{1}='NA';
            end
            
            %% Open C3D files via C3DServer
            Object1=c3dserver;
            openc3d(Object1,0,char(filePath));
            %% Import Force & Moment data
            if any(contains(upper(dataTypes),'FP'))
                %digital force
                % HRESULT GetForceData ( int  nCord , int  nFP , int  nStart , int  nEnd , VARIANT *  pData )
                % nCord       [in] This is the force data that you want to retrieve.  The valid values are: 0 = FX, 1 = FY and 2= FZ
                % nFP         [in] This is the zero based value of the force platform for which the force data needs to be calculated.  This should be >=0 and <= (Number of FP – 1)
                % nStart      [in] This is the first frame for which data needs to be calculated.  This needs to be sent in terms of video frames and is a 1 based value.
                % nEnd        [in] This is the last frame for which data needs to be calculated.  This needs to be sent in terms of video frames and is a 1 based value. The value of nEnd cannot be less than the value of nStart.  If both nStart and nEnd are –1, then all the frames of data are returned.
                % pData       [out] A pointer to a Variant object.  The value returned here is the force data for all the frames.  The value stored here will be a single precision real number.  The number of frames returned are calculated as: (nEnd – nStart + 1) * AnalogToVideoRatio
                fpFrameRate=Object1.GetAnalogVideoRatio*Object1.GetVideoFrameRate; % Sample rate of the mocap system * ratio of FP:mocap sample rate.
                FPrateMult=Object1.GetAnalogVideoRatio;
                importStruct.Subject(subNum).Info.FPSampleRate=fpFrameRate;
                tempF_FP=cell(length(fpNumbers),1); cardF_FP=cell(length(fpNumbers),1);
                tempM_FP=cell(length(fpNumbers),1); cardM_FP=cell(length(fpNumbers),1);
                tempCOP_FP=cell(length(fpNumbers),1); cardCOP_FP=cell(length(fpNumbers),1);
                tempTz_FP=cell(length(fpNumbers),1); cardTz_FP=cell(length(fpNumbers),1);
                fpCenter=cell(length(fpNumbers),1);
                compCOPIdx=cell(length(fpNumbers),1);
                fpCount=0;
                [fpNumbers,numIdx]=sort(fpNumbers); % Rearrange fpNumbers in increasing order.
                fpLetters=fpLetters(numIdx); % Rearrange fpLetters correspondingly.
                zerofpNumbers=fpNumbers-1; % Converts from 1-based numbering to 0-based numbering.
                clear getForce_FP;
                for zeroFpCount=zerofpNumbers % Iterate through forceplates used. Can handle numbers besides 1-N. Hopefully the c3d file indices ALWAYS match Motive FP order.
                    fpCount=fpCount+1; % In case the fpNumbers isn't perfectly 1-4.
                    currFPLetter=fpLetters(fpCount);
                    
                    if any(contains(upper(dataTypes),'MOCAP'))
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
                    if any(contains(upper(dataTypes),'MOCAP'))
                        cardCorners=mocapRotMatrix2Cardinal*currCorner;
                        importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).CornersCardinal(1:3,1:4)=cardCorners;
                        fpCenter{fpCount}(1:3,1)=mean(cardCorners,2);                    
                        importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).CenterCardinal=fpCenter{fpCount};
                    else                        
                        importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).CornersFP(1:3,1:4)=currCorner;
                        fpCenter{fpCount}(1:3,1)=mean(currCorner,2);                    
                        importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).CenterFP
                    end                    
                    
                    rotMatrix2Cardinal=ProjHelper.Info.FP.(currFPLetter).RefFrame.RotMatrix2Cardinal; % For forceplate kinetic data
                    h=ProjHelper.Info.FP.FPCoverThickness; % in meters.
                    
                    %% This is for Type 2: Fx, Fy, Fz, Mx, My, Mz (Bertec plates + Optitrack Motive setup)
                    % DON'T USE GetMomentData!!! Returns garbage data.
                    % Get analog data. Forces and Moments (Type 2 forceplates).
                    for channelNum=1:6
                        if channelNum<=3 % Forces
                            tempF_FP{fpCount}(channelNum,:)=cell2mat(Object1.GetAnalogDataEx(6*(fpCount-1)+channelNum-1,Object1.GetVideoFrame(0),Object1.GetVideoFrame(1),'0',0,1,'0'));
%                             currF=tempF_FP{fpCount};
%                             currF(currF==0)=NaN;
%                             tempF_FP{fpCount}(channelNum,:)=currF;
                        elseif channelNum>3 % Moments
                            tempM_FP{fpCount}(channelNum-3,:)=cell2mat(Object1.GetAnalogDataEx(6*(fpCount-1)+channelNum-1,Object1.GetVideoFrame(0),Object1.GetVideoFrame(1),'0',0,1,'0'));
%                             currM=tempM_FP{fpCount};
%                             currM(currM==0)=NaN;
%                             tempM_FP{fpCount}(channelNum,:)=currM;
                        end
                    end
                    
                    FzThresh=importStruct.Info.FP.COPFzThreshold;
                    compCOPIdx{fpCount}=false(length(tempF_FP{fpCount}),1); % Initialize to all false.
                    [~,k]=find(abs(tempF_FP{fpCount}(3,:))>=FzThresh); % Find indices where Fz larger than threshold.
                    compCOPIdx{fpCount}(k,1)=true(length(tempF_FP{fpCount}(3,k)),1); % Logical vector where 1 is enough Fz to compute COP.
                    largeFz=tempF_FP{fpCount}(3,:); % Initialize the Fz values that will have NaN in them.
                    largeFz(k)=NaN(length(k),1); % Contains only Fz values above the threshold.
                    tempCOP_FP{fpCount}(1,:)=(((-1*h).*tempF_FP{fpCount}(1,:)-tempM_FP{fpCount}(2,:))./largeFz); % COPx
                    tempCOP_FP{fpCount}(2,:)=(((-1*h).*tempF_FP{fpCount}(2,:)+tempM_FP{fpCount}(1,:))./largeFz); % COPy (multiplied by -1 for no apparent reason; now matches real world)
                    tempCOP_FP{fpCount}(3,:)=zeros(1,length(tempCOP_FP{fpCount}));
                    tempTz_FP{fpCount}=zeros(2,length(tempCOP_FP{fpCount}));
                    tempTz_FP{fpCount}(3,:)=tempM_FP{fpCount}(3,:)-(tempCOP_FP{fpCount}(1,:).*tempF_FP{fpCount}(2,:))+(tempCOP_FP{fpCount}(2,:).*tempF_FP{fpCount}(1,:));
                    
                    cardF_FP{fpCount}=rotMatrix2Cardinal*tempF_FP{fpCount};
                    cardM_FP{fpCount}=rotMatrix2Cardinal*tempM_FP{fpCount};
                    cardCOP_FP{fpCount}=rotMatrix2Cardinal*tempCOP_FP{fpCount}+repmat(fpCenter{fpCount},1,length(cardM_FP{fpCount})); % Rotates & translates.
                    cardTz_FP{fpCount}=rotMatrix2Cardinal*tempTz_FP{fpCount}; % Free moment
                    
                    % Forceplate info. Converts numbering from importSettings numbering system to
                    % c3d 1-N numbers.
                    importStruct.Info.FP.(strcat(['FP' currFPLetter])).RefFrame=ProjHelper.Info.FP.(currFPLetter).RefFrame;
                    importStruct.Subject(subNum).(strTrialName).Info.FP.(strcat(['FP' num2str(fpCount)])).Position_ID_Letter=currFPLetter;
                    importStruct.Subject(subNum).(strTrialName).Info.FP.(strcat(['FP' num2str(fpCount)])).AmpNum=ProjHelper.Info.FP.(currFPLetter).AmpSerial;
                    importStruct.Subject(subNum).(strTrialName).Info.FP.(strcat(['FP' num2str(fpCount)])).Position=ProjHelper.Info.FP.(currFPLetter).Position;
                    importStruct.Subject(subNum).(strTrialName).Info.FP.(strcat(['FP' num2str(fpCount)])).FPType=ProjHelper.Info.FP.(currFPLetter).FPType;
                    importStruct.Subject(subNum).(strTrialName).Info.FP.(strcat(['FP' num2str(fpCount)])).Size=ProjHelper.Info.FP.(currFPLetter).Size;
                    importStruct.Subject(subNum).(strTrialName).Info.FP.(strcat(['FP' num2str(fpCount)])).RotMatrix2Cardinal=rotMatrix2Cardinal;
                    
                    importStruct.Subject(subNum).(strTrialName).Info.FP.(strcat(['FP' num2str(fpCount)])).ComputeCOPFzLogical=compCOPIdx{fpCount}; % 1 when Fz over the threshold to compute COP.
                    
                    % Store kinetic data in local frame.
                    importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).ForceLocal=tempF_FP{fpCount}'; % N x 3
                    importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).MomentLocal=tempM_FP{fpCount}';
                    importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).COPLocal=tempCOP_FP{fpCount}';
                    importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).TzLocal=tempTz_FP{fpCount}';
                    
                    % Store kinetic data in cardinal frame.
                    importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).ForceCardinal=cardF_FP{fpCount}; % N x 3
                    importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).MomentCardinal=cardM_FP{fpCount};
                    importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).COPCardinal=cardCOP_FP{fpCount};
                    importStruct.Subject(subNum).(strTrialName).Data.FP.Raw.(strcat(['FP' num2str(fpCount)])).TzCardinal=cardTz_FP{fpCount};
                    
                    % Specify FP start and end frames.
                    if isnan(startFrame) % Not specified in logsheet.
                        FPstartFrame=1;
                    else
                        FPstartFrame=startFrame*FPrateMult-(FPrateMult-1); % Mocap and FP first datapoint are both frame 1. Mocap frame 2 occurs at FP frame (1 + FPrateMult).
                    end
                    if isnan(endFrame) % Not specified in logsheet.
                        FPendFrame=length(cardCOP_FP{fpCount});
                    else
                        FPendFrame=endFrame*FPrateMult;
                    end
                    FPlogVector=false(length(cardF_FP{fpCount}),1);
                    FPlogVector(FPstartFrame:FPendFrame)=true(FPendFrame-FPstartFrame+1,1);
                    importStruct.Subject(subNum).(strTrialName).Info.FP.StartEndIndices=[FPstartFrame FPendFrame];
                    importStruct.Subject(subNum).(strTrialName).Info.FP.LogicalVectorForIncludedFPSamples=FPlogVector;
                    importStruct.Subject(subNum).(strTrialName).Info.FP.CoverThicknessH_ForCOP=h;
                    
                end
                
                tempTime=nan(length(FPlogVector),1); % Initialize the time vector
                if isfield(importStruct.Subject(subNum).(strTrialName).Info,'ZeroEventMotiveFrameNumber') && ~isempty(importStruct.Subject(subNum).(strTrialName).Info.ZeroEventMotiveFrameNumber) && ~isnan(importStruct.Subject(subNum).(strTrialName).Info.ZeroEventMotiveFrameNumber{1})
                    zeroFrameNum=importStruct.Subject(subNum).(strTrialName).Info.ZeroEventMotiveFrameNumber{1}*FPrateMult;
                    tempTime(FPstartFrame:zeroFrameNum-1)=linspace(-(zeroFrameNum-FPstartFrame)/fpFrameRate,-1/fpFrameRate,zeroFrameNum-FPstartFrame);
                    tempTime(zeroFrameNum)=0;
                    tempTime(zeroFrameNum+1:FPendFrame)=linspace(1/fpFrameRate,(FPendFrame-zeroFrameNum)/fpFrameRate,FPendFrame-zeroFrameNum);
                    importStruct.Subject(subNum).(strTrialName).Info.FP.TimeVectorZeroAligned=true;
                else % Not aligned to zero
                    tempTime(FPstartFrame:FPendFrame,1)=linspace(0,(FPendFrame-FPstartFrame)/fpFrameRate,FPendFrame-FPstartFrame+1);
                    importStruct.Subject(subNum).(strTrialName).Info.FP.TimeVectorZeroAligned=false;
                end
                importStruct.Subject(subNum).(strTrialName).Info.FP.TimeVector=tempTime;

            end
            
            %% Import Mocap data
            % NEEDS CLEANING UP WHEN RECOGNIZING MOCAP DATA TYPES (e.g. labelled/unlabelled markers, clusters, etc.)
            if any(contains(upper(dataTypes),'MOCAP'))
                numMarkers=Object1.GetParameterLength(5);
                mocapFrameRate=Object1.GetVideoFrameRate; % Sample rate of the mocap system.
                importStruct.Subject(subNum).Info.MocapSampleRate=mocapFrameRate;
                
                firstFrame = Object1.GetVideoFrame(0); % c3dserver function
                lastFrame = Object1.GetVideoFrame(1); % c3dserver function
                if firstFrame==0 % 0-based frames exported
                    firstFrame=firstFrame+1;
                    lastFrame=lastFrame+1;
                end
                % Captures entire trial (if frames not specified in logsheet).
                if isnan(startFrame)
                    startFrame=firstFrame;
                end
                if isnan(endFrame)
                    endFrame=lastFrame;
                end
                
                importStruct.Subject(subNum).(strTrialName).Info.Mocap.RotMatrix2Cardinal=ProjHelper.Info.Mocap.RotMatrix2Cardinal;
                
                for currMarker=0:numMarkers-1  % through each marker
                    
                    tmp_varname=Object1.GetParameterValue(5,currMarker); % c3dserver function
                    
                    if ~isstring(tmp_varname) && ~ischar(tmp_varname)
                        badImport=1;
                        badTrialCount=badTrialCount+1;
                        importStruct.Info.Mocap.BadImportedTrials{badTrialCount,1}=subjectList{subNum,:};
                        importStruct.Info.Mocap.BadImportedTrials{badTrialCount,2}=trialNum;
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
                    
                    mocapLogVector=false(length(tempAllXYZData),1);
                    mocapLogVector(startFrame:endFrame)=true(endFrame-startFrame+1,1);
                    importStruct.Subject(subNum).(strTrialName).Info.Mocap.StartEndIndices=[startFrame endFrame];
                    importStruct.Subject(subNum).(strTrialName).Info.Mocap.LogicalVectorForIncludedMocapFrames=mocapLogVector;
                    % Mocap data should all be stored as Nx3 matrices!!!
                    importStruct.Subject(subNum).(strTrialName).Data.Mocap.Raw.Cardinal.(markerName)=(importStruct.Subject(subNum).(strTrialName).Info.Mocap.RotMatrix2Cardinal*tempAllXYZData)';
                    
                    tempTime=nan(length(tempAllXYZData),1);
                    if isfield(importStruct.Subject(subNum).(strTrialName).Info,'ZeroEventMotiveFrameNumber') && ~isempty(importStruct.Subject(subNum).(strTrialName).Info.ZeroEventMotiveFrameNumber) && ~isnan(importStruct.Subject(subNum).(strTrialName).Info.ZeroEventMotiveFrameNumber{1})
                        zeroFrameNum=importStruct.Subject(subNum).(strTrialName).Info.ZeroEventMotiveFrameNumber{1};
                        tempTime(startFrame:zeroFrameNum-1)=linspace(-(zeroFrameNum-startFrame)/mocapFrameRate,-1/mocapFrameRate,zeroFrameNum-startFrame);
                        tempTime(zeroFrameNum)=0;
                        tempTime(zeroFrameNum+1:endFrame)=linspace(1/mocapFrameRate,(endFrame-zeroFrameNum)/mocapFrameRate,endFrame-zeroFrameNum);
                        importStruct.Subject(subNum).(strTrialName).Info.Mocap.TimeVectorZeroAligned=true;
                    else % Not aligned to zero
                        tempTime(startFrame:endFrame)=linspace(0,(endFrame-startFrame)/mocapFrameRate,endFrame-startFrame+1);
                        importStruct.Subject(subNum).(strTrialName).Info.Mocap.TimeVectorZeroAligned=false;
                    end
                    importStruct.Subject(subNum).(strTrialName).Info.Mocap.TimeVector=tempTime;
                    
                    %% Gap Filling
                    importStruct.Subject(subNum).(strTrialName)=gapFill(importStruct.Subject(subNum).(strTrialName),markerName); % Modular gapfilling
%                     A= importStruct.Subject(subNum).(strTrialName).Data.Mocap.Raw.Cardinal.(markerName)';
%                     
%                     % Initialize
%                     importStruct.Subject(subNum).(strTrialName).Info.Mocap.Markers.GapCounter.(markerName)=0;
%                     importStruct.Subject(subNum).(strTrialName).Info.Mocap.Markers.GapIndices.(markerName)(1:length(A))=logical(false(1,length(A)));
% 
%                     if any(isnan(A),'all') % if nans are there instead of zeros
%                         %% Gap Filling .. expecting NaN if no mkr data
%                         %                     A= importStruct.Subject(subNum).(trialName).Mocap.Raw.(markerName);
%                         %             markerName
%                         importStruct.Subject(subNum).(strTrialName).Info.Mocap.Markers.GapCounter.(markerName)=sum(isnan(A(:,1))); % scalar count
%                         
%                         if importStruct.Subject(subNum).(strTrialName).Info.Mocap.Markers.GapCounter.(markerName)>=.97*length(A) %if more than 97% of trial is NaNs, make all data zeros
%                             %                         A=zeros(size(A));
%                             if ~contains(markerName,{'UNLABELED','UNASSIGNED'})
%                                 importStruct.Subject(subNum).(strTrialName).Info.Mocap.Markers.GapIndices.(markerName)(1:length(A))=logical(true(1,length(A)));
%                                 importStruct.Subject(subNum).(strTrialName).Info.IsPerfect{1}=0;
%                                 importStruct.Subject(subNum).(strTrialName).Info.NotPerfectBecause{1}='All Data NaN';
%                             end
%                             
%                         else %otherwise, if it's a small gap, fill it with its previous value
%                             for index=1:length(A)
%                                 if isnan(A(index,1)) && index==1
%                                     firstValueIndex=find(~isnan(A),1);
%                                     A(index,1:3)=A(firstValueIndex,1:3);
%                                     %                             A(index,1:3)=nanmean(A(:,1:3)); % don't use
%                                     %                             this unless you want to fill prior nans with
%                                     %                             mean data across whole trial!
%                                     importStruct.Subject(subNum).(strTrialName).Info.Mocap.Markers.GapIndices.(markerName)(index)=logical(true);
%                                 end
%                                 if isnan(A(index,1))  && index>=2
%                                     A(index,1:3)=A(index-1,1:3);
%                                     importStruct.Subject(subNum).(strTrialName).Info.Mocap.Markers.GapIndices.(markerName)(index)=logical(true);
%                                 end
%                             end
%                         end
%                         importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)=A;
%                     else % no gap
%                         importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)=A;
%                         importStruct.Subject(subNum).(strTrialName).Info.Mocap.Markers.GapIndices.(markerName)(1:length(importStruct.Subject(subNum).(strTrialName).Data.Mocap.Raw.Cardinal.(markerName)))=false;
%                         
%                     end
%                     
%                     clear A
                    
                end
                
                % The if statement ensures that some/any mocap data for this trial was actually imported
                if badImport==0 % Trial wasn't imported just wrongly from the c3d file. Don't know why this happens sometimes.
                    %% STEP 1 B: Smooth with CSAPS,
                    importStruct.Subject(subNum).(strTrialName)=smooth_CSAPS(importStruct.Subject(subNum).(strTrialName));
                    marker_names=fieldnames(importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal);
%                     for m=1:length(marker_names)
%                         markerName=upper(marker_names{m});
%                         if importStruct.Subject(subNum).(strTrialName).Info.Mocap.Markers.GapCounter.(markerName)==0 % Number of gaps=0
%                             importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)=importStruct.Subject(subNum).(strTrialName).Data.Mocap.Raw.Cardinal.(markerName);
%                         else
%                             if ~contains(markerName,'UNLABELED') % Don't smooth Unlabeled data.
%                                 
%                                 %CSAPS TO SMOOTH IF THERE WERE GAPS
%                                 p = .2; %csaps threshold the larger the number, the more conservative the smoothing is...
%                                 for xyz=1:3
%                                     x=[1: length(importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)(:,xyz))].';
%                                     y=double(importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)(:,xyz));
%                                     if isempty(x) || isempty(y) || sum(y)==0
%                                         importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)(:,xyz)=y;
%                                     else
%                                         out = csaps(x,y,p);
%                                         importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)(:,xyz)=fnval(x,out);
%                                     end
%                                 end
%                             end
%                         end
%                         % Check data matrix sizing for rotation. Don't double
%                         % rotate! The raw data should already be in the Cardinal frame.
%                         if size(importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName),1)~=size(importStruct.Subject(subNum).(strTrialName).Info.Mocap.RotMatrix2Cardinal,1)
%                             %                         importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)=importStruct.Subject(subNum).(strTrialName).Info.Mocap.RotMatrix2Cardinal*(importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)');
%                             importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)=importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)';
%                         else
%                             %                         importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)=importStruct.Subject(subNum).(strTrialName).Info.Mocap.RotMatrix2Cardinal*importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName);
%                             importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName)=importStruct.Subject(subNum).(strTrialName).Data.Mocap.GapFilled.Cardinal.(markerName);
%                         end
%                     end
                    
                    %% Sort Markers' names into segments
                    segMarkerCount=zeros(length(importStruct.Info.Mocap.SegmentList),1);
                    prevMarkerSegs=segMarkerCount;
                    for m=1:length(marker_names)
                        [~,~,seg]=feval(['importSettings' projectName],marker_names{m});
                        segIdxs=find(segMarkerCount~=prevMarkerSegs);
                        for ii=1:size(seg,1)
                            currSeg=seg{ii};
                            importStruct.Subject(subNum).(strTrialName).Info.Mocap.Segments.(currSeg).MarkerNames{segMarkerCount(segIdxs(ii))}=upper(marker_names{m}); % Only assigning marker names, not data.
                        end
                        prevMarkerSegs=segMarkerCount;
                    end
                    
                end
                
            end
            
            %% Import IMU data
            if any(contains(upper(dataTypes),'IMU'))
                
            end
            
            %% Import EMG data
            if any(contains(upper(dataTypes),'EMG'))
                
            end
            
            closec3d(Object1);
            importStruct.Subject(subNum).(strTrialName).Info.ImportProcessed=true; % Flag to indicate this trial has been successfully imported.
            
        end % End of processing for that trial.
        
    end
    
    cd ../.. %I'm a nifty coder and this goes up 2 levels
    
end
%% Handle EMGData
% Needs to be able to handle multiple trials within one file.
% Right now this code cannot do this.
if any(contains(dataTypes,'EMG'))
    for subNum=1:NumofSubs
        noraxonLocation=fullfile((strtrim(subjectList(subNum,:))),'Noraxon');
        % Check if there is a Noraxon folder
        if (exist(noraxonLocation,'file')==0)
            continue; % if not, skip this subject
        end
        cd (noraxonLocation);
        filesList= ls('*.mat'); % Find a list of all trials
        if size(filesList)==0
            error('No trials found');
        end
        subRow =find(strcmp(batchRaw(:,subIDCol),strtrim(subjectList(subNum,:))),1); %find first row for subject
        if isempty(subRow)
            warning('Subject Row not found');
            pause(5)
        end
        for trialNum=1:size(filesList)
            noraxonTrialNameint = strtrim(filesList(trialNum,:)); % save trial name without spaces or .mat extension
            noraxonTrialName = ['TRIAL' noraxonTrialNameint(end-7:end-4)]; % save trial name without spaces or .mat extension
            
            strTrialName = noraxonTrialName; %cell2mat(batchRaw(trialRow,motiveTrialCol));
            noraxonTrialNameImport=strtrim(filesList(trialNum,:));
            trialPathImport=fullfile(pwd,noraxonTrialNameImport);
            
            trialRow =find(strcmp(batchRaw(subRow:end,noraxonTrialCol),noraxonTrialNameImport(1:end-4)))+subRow-1; %find trial row %Looks at whole name
            %         trialRow =find(contains(batchRaw(subRow:end,noraxonTrialCol),noraxonTrialName(end-3:end)),1)+subRow-1; %find trial row %Looks at last 3 characters
            %         trialRow =find(strfind(batchRaw(subRow:end,noraxonTrialCol),noraxonTrialName(end-3:end)),1)+subRow-1; %find trial row
            if isempty(trialRow)
                warning('Trial Row not found');
            end
            %             noraxonTrialName
            if isempty(trialRow)
                warning('Trial Row not found');
                pause(5)
            end
            %         noraxonTrialName
            
            keyList=subInfoColMap.keys;
            for keyNum=1:size(keyList,2) % Populate subject level info fields
                importStruct.Subject(subNum).Info.(keyList{keyNum})= batchRaw(subRow,subInfoColMap(keyList{keyNum}));
            end
            % If current trial has not been processed at all yet
            if ~(isfield(importStruct,'Subject'))
                keyList=trialInfoColMap.keys;
                for keyNum=1:size(keyList,2) % Populate subject level info fields
                    importStruct.Subject(subNum).(strTrialName).Info.(keyList{keyNum})= batchRaw(trialRow,trialInfoColMap(keyList{keyNum}));
                end
            elseif ~(isfield(importStruct.Subject(subNum),strTrialName))
                keyList=trialInfoColMap.keys;
                for keyNum=1:size(keyList,2) % Populate subject level info fields
                    importStruct.Subject(subNum).(strTrialName).Info.(keyList{keyNum})= batchRaw(trialRow,trialInfoColMap(keyList{keyNum}));
                end
            elseif isempty(importStruct.Subject(subNum).(strTrialName))
                keyList=trialInfoColMap.keys;
                for keyNum=1:size(keyList,2) % Populate subject level info fields
                    importStruct.Subject(subNum).(strTrialName).Info.(keyList{keyNum})= batchRaw(trialRow,trialInfoColMap(keyList{keyNum}));
                end
            end
            % Import EMGData
            load (trialPathImport);
            importStruct.Subject(subNum).(strTrialName).Info.EMGSampRate=double(round(samplingRate));
            
            [~,numChannels]=size(channelNames);
            % Prepare/presize bins
            binSize=round(0.02*samplingRate); %number of samples per bin % samplingRate comes in automatically with each trial's mat file
            
            
            for currChannel=1:numChannels
                channelName=cell2mat(channelNames(currChannel)); % change from cell to char
                if strcmp(channelName,'Time') || ~isempty(strfind(channelName,'Noraxon'))  %weird mat file with first channel name as 'Time'
                    
                else
                    
                    if strcmp(cell2mat(channelNames(1)),'Time')
                        if strcmp(projectName,'Pitching')
                            channelName=channelName(1:strfind(channelName,',')-1);% cut out name of channel after ','
                        else (strcmp(projectName,'ShoulderArthro') && subNum>=10)
                            channelName=channelName(1:strfind(channelName,',')-4);% cut out name of channel after ','
                        end
                        channelName=channelName(isstrprop(channelName,'alpha'));% only care about alpha char in string
                    else
                        channelName=channelName(4:strfind(channelName,',')-1);% cut out name of channel after ','
                        channelName=channelName(isstrprop(channelName,'alpha'));% only care about alpha char in string
                    end
                    
                    importStruct.Subject(subNum).(strTrialName).EMGData.Raw.(channelName).Info.SamplingRate=samplingRate; % store sample rate
                    tempDataHold=Data(1,currChannel);
                    importStruct.Subject(subNum).(strTrialName).EMGData.Raw.(channelName).Data=cell2mat(tempDataHold(1,1)); % store raw data
                end
            end
            
            EmgChannelLength=length(fieldnames(importStruct.Subject(subNum).(strTrialName).EMGData.Raw));
            Channels=fieldnames(importStruct.Subject(subNum).(strTrialName).EMGData.Raw);
            
            figure('Visible','off') %figure for raw data plots for each trial
            title(['RawEMG_Trial_' strTrialName 'Subj_' num2str(subNum)])
            hold on
            for currChannel=1:EmgChannelLength % last two are external trigger / sync pulse signals
                channelName=cell2mat(Channels(currChannel));
                subplot (EmgChannelLength,1,currChannel)
                hold on
                %% plot raw EMG for each trial
                plot(importStruct.Subject(subNum).(strTrialName).EMGData.Raw.(channelName).Data)
                hold on
                ylabel(channelName)
                set(get(gca,'ylabel'),'rotation',0)
                %% Filter, rectify, and bin all trials (including MMT trials)
                % DO NOT SHIFT NORAXON DATA shift to remove offset
                %             tempDataHoldShifted= importStruct.Subject(subNum).(trialName).EMGData.Raw.(channelName).Data(1,1) - ones(length(tempDataHold{1,1}),1)*mean(importStruct.Subject(subNum).(trialName).EMGData.Raw.(channelName).Data);
                tempDataHoldShifted=importStruct.Subject(subNum).(strTrialName).EMGData.Raw.(channelName).Data;
                % Filter
                if contains(channelName,'PEC') || contains(channelName,'OBL') contains(channelName,'RECTAB')
                    [B,A] = butter(4, [40/(samplingRate/2) 400/(samplingRate/2)]); %change double to single?
                else
                    [B,A] = butter(4, [10/(samplingRate/2) 400/(samplingRate/2)]); %change double to single?
                end
                tempDataHoldFilt=filtfilt(B,A,tempDataHoldShifted);
                
                % Rectify
                tempDataHoldFiltRectified=sqrt(tempDataHoldFilt.^2); % root mean sq. or "rms" fcn for future
                importStruct.Subject(subNum).(strTrialName).EMGData.FilteredRectified.(channelName).Data=tempDataHoldFiltRectified;
                
                %% Handle EMG delay
                if samplingRate==3000
                    EMGdelayNumIndices=round(0.156/(1/samplingRate));
                else %1500
                    EMGdelayNumIndices=round(0.312/(1/samplingRate));
                end
                importStruct.Subject(subNum).(strTrialName).EMGData.FilteredRectifiedTimeShift.(channelName).Data=importStruct.Subject(subNum).(strTrialName).EMGData.FilteredRectified.(channelName).Data(EMGdelayNumIndices:end);
                padEndWithNZeros=EMGdelayNumIndices-1;
                importStruct.Subject(subNum).(strTrialName).EMGData.FilteredRectifiedTimeShift.(channelName).Data(end+1:end+padEndWithNZeros)=zeros(padEndWithNZeros,1);
                % Bin
                numBins=ceil(length(importStruct.Subject(subNum).(strTrialName).EMGData.FilteredRectifiedTimeShift.(channelName).Data)/binSize); % number of bins (includes final bin that may not have (binSize) number of samples)
                
                % run through each filled bin
                importStruct.Subject(subNum).(strTrialName).EMGData.Binned.(channelName).Data = mean(reshape(importStruct.Subject(subNum).(strTrialName).EMGData.FilteredRectifiedTimeShift.(channelName).Data(1:numBins*binSize-binSize),binSize,(numBins*binSize-binSize)/binSize))';
                
                % max binned value during MMT trial
                if strcmp(strrep(cell2mat(importStruct.Subject(subNum).(strTrialName).Info.Task),' ',''), channelName)
                    EMGMaxManualMuscleTest.(channelName)=max(importStruct.Subject(subNum).(strTrialName).EMGData.Binned.(channelName).Data);
                else
                end
            end
            
            saveas(gcf,['RawEMG_Trial_' strTrialName '_Subj_' num2str(subNum)],'jpg');
            %         saveas(gcf,['RawEMG_Trial_' trialName '_Subj_' num2str(subNum)],'fig');
            close gcf
            
            
            figure('Visible','off') %figure for binned data plots for each trial
            for currChannel=1:EmgChannelLength % last two are external trigger / sync pulse signals
                subplot (EmgChannelLength,1,currChannel)
                hold on
                channelName=cell2mat(Channels(currChannel));
                plot(importStruct.Subject(subNum).(strTrialName).EMGData.Binned.(channelName).Data)
                ylabel(channelName)
                set(get(gca,'ylabel'),'rotation',0)
            end
            %temporarily commented out due to error using saveas-> print
            saveas(gcf,['BinnedEMG_Trial_' strTrialName '_Subj_' num2str(subNum)],'jpg');
            %         saveas(gcf,['BinnedEMG_Trial_' trialName '_Subj_' num2str(subNum)],'fig');
            close gcf
        end
        for trialNum=1:size(filesList)
            noraxonTrialNameint = strtrim(filesList(trialNum,:)); % save trial name without spaces or .mat extension
            noraxonTrialName = ['TRIAL' noraxonTrialNameint(end-7:end-4)]; % save trial name without spaces or .mat extension
            
            strTrialName = noraxonTrialName; %cell2mat(batchRaw(trialRow,motiveTrialCol));
            noraxonTrialNameImport=strtrim(filesList(trialNum,:));
            trialPathImport=fullfile(pwd,noraxonTrialNameImport);
            
            trialRow =find(strcmp(batchRaw(subRow:end,noraxonTrialCol),noraxonTrialNameImport(1:end-4)))+subRow-1; %find trial row %Looks at whole name
            
            if isempty(trialRow)
                warning('Trial Row not found');
                pause(5)
            end
            
            if isnan(strTrialName)
                strTrialName=noraxonTrialName(end-8:end);
            end
            figure('Visible','off') %figure for normalized binned data plots for each trial
            
            for currChannel=1:EmgChannelLength
                channelName=cell2mat(Channels(currChannel)); % change from cell to char
                
                
                % normalize to that channel's "MaxManualMuscleTest"
                importStruct.Subject(subNum).(strTrialName).EMGData.BinnedNormalized.(channelName).Data=bsxfun(@rdivide,importStruct.Subject(subNum).(strTrialName).EMGData.Binned.(channelName).Data,EMGMaxManualMuscleTest.(channelName))*100;
                %create info structure for that binned trial
                importStruct.Subject(subNum).(strTrialName).EMGData.BinnedNormalized.(channelName).Info.sampleRate=importStruct.Subject(subNum).(strTrialName).EMGData.Raw.(channelName).Info.SamplingRate/binSize; % store sample rate
                %figure for binned data plots for each trial
                hold on
                subplot (EmgChannelLength,1,currChannel)
                hold on
                plot(importStruct.Subject(subNum).(strTrialName).EMGData.BinnedNormalized.(channelName).Data)
                ylabel(channelName)
                set(get(gca,'ylabel'),'rotation',0)
                
            end
            
            
            saveas(gcf,['BinnedNormalizedEMG_Trial_' strTrialName '_Subj_' num2str(subNum)],'jpg');
            %         saveas(gcf,['BinnedNormalizedEMG_Trial_' trialName '_Subj_' num2str(subNum)],'fig');
            close gcf
        end
        
        cd ../.. %I'm a nifty coder and this goes up 2 levels
    end
end
cd

% figure('Visible','on')
% close all
% end

%% Save the importStruct variable.
batchRaw2=batchRaw(1:trialRow,:); % Trim the logsheet variable if necessary.
newStructName=strcat([projectName '_ImportStruct']);
if ~isfield(importStruct,'Logsheet')
    importStruct.Logsheet=batchRaw2;
end
saveLoc=strcat([projectPath '\MatDataFiles\']);
if ~isfolder(saveLoc)
    mkdir(saveLoc);
end
eval([newStructName '=importStruct']); % Rename the importStruct to project-specific variable name for saving.
currDate=char(datetime('now'));
saveName=[saveLoc projectName ' Imported Data ' currDate(1:end-9) 'V1.mat'];

%% Saving schema: All files from later processing steps that use this exact imported data will have the same date in their file names.
% Different versions of saved data will have different version numbers, but the same date if using same exact import code
% If there's already a file matching this name in the folder, then increment the version number until the name is unique.
% listing=dir;
% while uniqueName==0 % While the name is not unique.
%     uniqueName=1; % Initialize to the save name being unique.
%     for i=1:length(listing) % Keep iterating through the listing, assuming no particular order.
%         if length(listing(i).name)>3 && isequal(listing(i).name,saveName)
%             uniqueName=0; % Indicates the name is not unique.
%             nameLength=length(listing(i).name); % Name of the file
%             if regexp(listing(i).name(end-4),'[0-9]') && isequal(listing(i).name(end-3),'.') % Check if the V number is < 10. end-4=number and end-3='.' 
%                 verNum=str2double(saveName(end-4)); % Get the version number
%                 startNumIdx=nameLength-4; % Just after the V for version
%             elseif regexp(listing(i).name(end-5:end-4),'[0-9][0-9]') && isequal(listing(i).name(end-3),'.') % If V>=10, end-5=number, end-4=number, and end-3='.'
%                 verNum=str2double(saveName(end-5:end-4)); % Get the version number  
%                 startNumIdx=nameLength-5; % Just after the V for version
%             end            
%             verNum=verNum+1; % Increase the version number by 1.
%             suffixLength=length([num2str(verNum) '.mat']);
%             saveName(startNumIdx:startNumIdx+suffixLength)=[num2str(verNum) '.mat'];            
%         end
%     end
% end
importStruct.Info.FileNames.Import=saveName;
save(saveName,newStructName,'-v7.3');