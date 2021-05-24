% importSettingsSoundBalance
% This function is used during addTrial and importAndFill to:
% 1)	match SubjectInfo Info and Trial Info labels to the proper column in the logsheet
% Outputs projectName, subInfoMap, trialInfoMap. See Map and ProjectStruct for more.
% 2)	initially sort markers into the proper segment (ex: LUPARM)
% Outputs seg
% 3)	sort markers into the proper generalized segments (ex: UPARM)
% Outputs seg, modifiedMarkerName
%
% Inputs:
% markerName – name of the current marker
% sideOfInterest – side of interest for the current SubjectInfo
% sortPhase – phase of the segment sorting; 1 is initial sort, 2 is alternate sort
% Outputs:
% output1 – projectName  or seg (2, 3)
% output2 – subInfoMap  or modifiedMarkerName
% output3 – trialInfoMap
% Matt Perek 3/27/18

% Update Log
% 3/27/18 MP - Initially written from importAndFillVolleyball
% 4/19/18 MP - Updated documentation
% 6/14/18 AZ - added general uparm and farm segments (end 2 fcn loops)-
% commented out

%% MT EDIT NOTES BEGIN HERE
% How will I manage project-specific values for attributes common to many projects?
% 1. Which data is represented in this project? Mocap, forceplates, IMU, EMG, etc.
% 2. How to deal with (specify) different markersets (one per project).
% 3. How to specify & adjust for various reference frames (e.g. forceplates vs. world)
% 4. How to store (& deal with?) various numbers of sensors & sensor placements.
% 5. How to manage files (typically calibration) with multiple trials per file.

function [ProjHelper,dataTypes,segment]=importSettingsSpr21TWWBiomechanics(markerName)
global segMarkerCount;
if(nargin==0) % called early in importAndFill.m
    
    ProjHelper.Info.PhaseDefsThresholdTaskName='Straight Line Gait'; % This name should match the logsheet task type entry for the task that is used to generate threshold values for the phase definitions.
    ProjHelper.Info.TaskOfIntName='TWW'; % This is the task I'll be computing biomechanical metrics & running stats for.
    ProjHelper.Info.StaticCalTaskName='Static Height Weight Cal'; % This is the task that is quiet standing, to generate the height, weight (if FP), & head model.
    ProjHelper.Info.DynamicCalTaskName='Dynamic Cal'; % Dynamic calibration task.
    ProjHelper.Info.DynamicCalJoints=["LHIP";"RHIP"]; % Joints to generate in the dynamic calibration task.
    ProjHelper.Info.DynamicCalJointsSegments=["TRUNK LTHIGH";"TRUNK RTHIGH"]; % Listed proximal to distal. Segments used to generate the dynamic calibration joints.
    ProjHelper.Info.StaticCalJoints=["LSHOULDER";"RSHOULDER"]; % Joints to generate in the static calibration task.
    ProjHelper.Info.StaticCalJointsSegments=[{"TRUNK","LUARM"};{"TRUNK","RUARM"}]; % Listed proximal to distal. Segment names used to generate the static calibration joint center.
    ProjHelper.Info.MaxHoldDur=100; % Maximum number of frames to hold TBCM for.
    
    location='EAS 102 MSKCD Lab';
    ProjHelper.Info.DataCollectionSite=location;
    subjectListInStruct=["02_Nairobi"; "03_Tokyo"; "04_Denver"; "06_Berlin";]; % Folders to enter. Should match folder name and logsheet codename.
%     subjectListInStruct=["03_Tokyo"]; % All subjects to be in the structure.
    ProjHelper.Info.SubjectList=subjectListInStruct;
    
    % Motion capture data = 'mocap'
    % EMG data = 'EMG'
    % IMU data = 'IMU'
    % Forceplate data = 'FP'
    %         dataTypes={'MOCAP'}; % Cell array containing chars.
    dataTypes={'MOCAP','FP'};
    ProjHelper.Info.DataTypes=dataTypes;
    
    % This is the ground truth coordinate system that the data will be
    % reported in.
    % EAS lab space.
    ProjHelper.Info.Cardinal.PosX='E';
    ProjHelper.Info.Cardinal.PosY='N';
    ProjHelper.Info.Cardinal.PosZ='Up';
    ProjHelper.Info.Cardinal.RHandRule='Yes';
    
    % Future project helper functions won't have if statement code here.
    % They'll copy only the info. code for the data they use.
    if any(contains(dataTypes,'MOCAP'))
        rigidBodyNames=upper({'NorthTripod','SouthTripod'});
        ProjHelper.Info.Mocap.RigidBodyNames=rigidBodyNames;
        rigidBodyMarkerNames=upper({'NorthTripod1'; 'NorthTripod2'; 'NorthTripod3'; 'NorthTripod4'; 'SouthTripod1'; 'SouthTripod2'; 'SouthTripod3'; 'SouthTripod4'});
        ProjHelper.Info.Mocap.RigidBodyMarkerNames=rigidBodyMarkerNames;
        virtualMarkerNames=sort({'LHIP';'RHIP';'LSHOULDER';'RSHOULDER';'VHTOP'}); % Marker names for data to be placed into static calibration "reference" trial.
        ProjHelper.Info.Mocap.VirtualMarkerNames=virtualMarkerNames;
        coreRefAnatMarkerNames=sort({'RHME'; 'LHME'; 'RFME'; 'LFME'; 'RTAM'; 'LTAM'; 'LFM2'; 'RFM2'}); % Does this need to be subject-specific?
        bosMarkerNames=sort({'LDP1','LFCC','LFM1','LFM5','RDP1','RFCC','RFM1','RFM5'}); % Does this need to be subject-specific?
        % Subject-independent reference list of marker names.
        coreRefTrackingMarkerNames=sort({'CV7';'LAH';'LCAJ';'LDP1';'LFAL';'LFAX';'LFCC';'LFLE';'LFM1';'LFM5';'LFTC';'LHGT';'LHLE';'LHM2';'LIAS';'LIPS';...
            'LPH';'LRSP';'LSK';'LTH';'LTTC';'LUA';'LUSP';'RAH';'RCAJ';'RDP1';'RFAL';'RFAX';'RFCC';'RFLE';'RFM1';'RFM5';'RFTC';'RHGT';...
            'RHLE';'RHM2';'RIAS';'RIPS';'RPH';'RRSP';'RSK';'RTH';'RTTC';'RUA';'RUSP';'SJN';'SXS';'TV2';'TV7'});
        % Per-subject additional markers: NONE of these tracking markers should be directly involved in setting up the anatomic axes in static or dynamic trial.
        % NOTE: I don't think anatomic markers should ever be subject-specific? As they're used to construct the anatomic axes, and those shouldn't change person to person.
        for i=1:length(subjectListInStruct)
            if isequal(subjectListInStruct(i),"06_Berlin") || isequal(subjectListInStruct(i),"07_Oslo") % Oslo won't be analyzed due to poor tracking.
                ProjHelper.Info.Mocap.Subject(i).AddTrackingMarkerList=sort({'LTHIGH_4';'LTHIGH_5';'RTHIGH_4';'RTHIGH_5'});
%                 ProjHelper.Info.Mocap(i).AddAnatMarkerList=sort({}); % Not used for now!
            elseif isequal(subjectListInStruct(i),"08_Oxford")
                ProjHelper.Info.Mocap.Subject(i).AddTrackingMarkerList=sort({'LTHIGH_3';'LTHIGH_4';'RTHIGH_3';'RTHIGH_4'});
%                 ProjHelper.Info.Mocap(i).AddAnatMarkerList=sort({}); % Not used for now!
            else % This is the default, with no additional markers beyond the core tracking markers.
                ProjHelper.Info.Mocap.Subject(i).AddTrackingMarkerList=sort({});
            end
            ProjHelper.Info.Mocap.Subject(i).TrackingMarkerList=sort(vertcat(coreRefTrackingMarkerNames,ProjHelper.Info.Mocap.Subject(i).AddTrackingMarkerList));
%             ProjHelper.Info.Mocap.Subject(i).AnatMarkerList=sort(vertcat(coreRefAnatMarkerNames,ProjHelper.Info.Mocap.Subject(i).AddAnatMarkerList));
        end    
        ProjHelper.Info.Mocap.AnatMarkerList=coreRefAnatMarkerNames;
        ProjHelper.Info.Mocap.BOSMarkerNames=bosMarkerNames;                
        % Segment list helps with properly allocating the marker names to their segments.
        ProjHelper.Info.Mocap.SegmentList=upper(sort(["Head","LFArm","LFoot","LHand","LShank","LThigh","LUArm","RFArm","RFoot","RHand","RShank","RThigh","RUArm","Trunk","Unassigned","Unlabeled"])); % Includes Unassigned.
        % IN ALPHABETICAL ORDER BY SEGMENT: HEAD, LFARM, LFOOT, LHAND, LSHANK, LTHIGH, LUARM, RFARM, RFOOT, RHAND, RSHANK, RTHIGH, RUARM, TRUNK    
        % Zatsiorsky book/De Leva 1996 paper. Bottom half of the table.
        comPercLocM=[0.5002; 0.4574; 0.4415; 0.3624; 0.4459; 0.4095; 0.5772; 0.4574; 0.4415; 0.3624; 0.4459; 0.4095; 0.5772; 0.5138;]; % Males: Percent down longitudinal axis of each segment (proximal to distal) of CoM.
        comPercLocF=[0.4841; 0.4559; 0.4014; 0.3427; 0.4416; 0.3612; 0.5754; 0.4559; 0.4014; 0.3427; 0.4416; 0.3612; 0.5754; 0.4964;]; % Females: Percent down longitudinal axis of each segment (proximal to distal) of CoM.
        ProjHelper.Info.Mocap.Male.COMPercLoc=comPercLocM;
        ProjHelper.Info.Mocap.Female.COMPercLoc=comPercLocF;
        % IN ALPHABETICAL ORDER BY SEGMENT: HEAD, LFARM, LFOOT, LHAND, LSHANK, LTHIGH, LUARM, RFARM, RFOOT, RHAND, RSHANK, RTHIGH, RUARM, TRUNK 
        segWeightsM=[0.0694; 0.0162; 0.0137; 0.0061; 0.0433; 0.1416; 0.0271; 0.0162; 0.0137; 0.0061; 0.0433; 0.1416; 0.0271; 0.4346];
        segWeightsF=[0.0668; 0.0138; 0.0129; 0.0056; 0.0481; 0.1478; 0.0255; 0.0138; 0.0129; 0.0056; 0.0481; 0.1478; 0.0255; 0.4257];
        ProjHelper.Info.Mocap.Male.SegWeights=segWeightsM;
        ProjHelper.Info.Mocap.Female.SegWeights=segWeightsF;
        % Moments of inertia are from Zatsiorsky Kinetics book. Males: P. 304 for segment I's & weights, Females: P. 590 for I & weights. And p. 609 for segment lengths.
        % Originally given as kg*cm^2, so divide by 10^4 to convert to kg*m^2
        % IN ALPHABETICAL ORDER BY SEGMENT: HEAD, LFARM, LFOOT, LHAND, LSHANK, LTHIGH, LUARM, RFARM, RFOOT, RHAND, RSHANK, RTHIGH, RUARM, TRUNK 
        ProjHelper.Info.Mocap.Male.MomentofInertia.X=[272.1 64.7 44 13.2 385 1997.8 127.3 64.7 44 13.2 385 1997.8 127.3 NaN]/(10^4); % Moment of inertia about segment X (AP) axis.
        ProjHelper.Info.Mocap.Male.MomentofInertia.Y=[293.9 60.2 40 8.76 371 1999.4 114.4 60.2 40 8.76 371 1999.4 114.4 NaN]/(10^4); % Moment of inertia about segment Y (ML) axis.
        ProjHelper.Info.Mocap.Male.MomentofInertia.Z=[202.4 12.6 10.3 5.37 64.6 413.4 38.95 12.6 10.3 5.37 64.6 413.4 38.95 NaN]/(10^4); % Moment of inertia about segment Z (longitudinal) axis.
        ProjHelper.Info.Mocap.Female.MomentofInertia.X=[183.6 40.9 41.1 6 409.9 1690.1 92.3 40.9 41.1 6 409.9 1690.1 92.3 NaN]/(10^4); % Moment of inertia about segment X (AP) axis.
        ProjHelper.Info.Mocap.Female.MomentofInertia.Y=[216.5 39.7 35.6 4.4 399.7 1647.3 80.7 39.7 35.6 4.4 399.7 1647.3 80.7 NaN]/(10^4); % Moment of inertia about segment Y (ML) axis.
        ProjHelper.Info.Mocap.Female.MomentofInertia.Z=[172.7 5.3 8.9 2.4 48.6 324.2 26.2 5.3 8.9 2.4 48.6 324.2 26.2 NaN]/(10^4); % Moment of inertia about segment Z (longitudinal) axis.
        % EAS lab space.
        ProjHelper.Info.Mocap.RefFrame.PosX='W';
        ProjHelper.Info.Mocap.RefFrame.PosY='Up';
        ProjHelper.Info.Mocap.RefFrame.PosZ='N';
        ProjHelper.Info.Mocap.RefFrame.RHandRule='Yes';
        [mocapRefFrameRotMatrix]=ref2cardFrameRotMatrix(ProjHelper.Info.Cardinal,ProjHelper.Info.Mocap.RefFrame);
        ProjHelper.Info.Mocap.RotMatrix2Cardinal=mocapRefFrameRotMatrix;
    end
    %% Forceplate information for the project.
    if any(contains(dataTypes,'FP'))
        
        % Logsheet will contain a column for mapping Motive FP order number
        % to the real-world forceplate position.
        % e.g. 'A1 B2 C3 D4 E5' OR 'A2 B4 C3 D1 E5' etc. as appropriate.
        % Letters = real-world forceplate position (see the map elsewhere/comments here).
        % Numbers = Motive FP order number.
        % Key: A=Large portable, B=NW in-ground, C=SW in-ground, D=NE in-ground, E=SE in-ground
        
        ProjHelper.Info.FP.FPCoverThickness=0.003; % thickness in meters of any material (flooring) covering FP's.
        ProjHelper.Info.FP.COPFzThreshold=50; % In Newtons. Below this, COP is not computed.
        
        % Identify number of forceplates used in this project.
        ProjHelper.Info.FP.NumberOfFP=4;
        
        % 'IG' if in-ground permanent FP, 'SP' if small portable, 'LP' if large portable.
        
        % Forceplate reference frames in terms of cardinal directions.
        % Works well in Zaferiou lab, as FP's are aligned with walls & can
        % therefore approximate cardinal directions.
        ProjHelper.Info.FP.A.Position='W';
        ProjHelper.Info.FP.A.AmpSerial='S038964';
        ProjHelper.Info.FP.A.FPType='LP';% Large portable.
        ProjHelper.Info.FP.A.Size=[23.62 35.43];
        ProjHelper.Info.FP.A.RefFrame.PosX='W';
        ProjHelper.Info.FP.A.RefFrame.PosY='N';
        ProjHelper.Info.FP.A.RefFrame.PosZ='Down'; % Up or down.
        ProjHelper.Info.FP.A.RefFrame.RHandRule='Yes'; % 'Yes' or 'No' if ref frame follows the R hand rule.
        [refFrameRotMatrix]=ref2cardFrameRotMatrix(ProjHelper.Info.Cardinal,ProjHelper.Info.FP.A.RefFrame);
        ProjHelper.Info.FP.A.RefFrame.RotMatrix2Cardinal=refFrameRotMatrix;
        ProjHelper.Info.FP.B.Position='NW';
        ProjHelper.Info.FP.B.AmpSerial='S039698';
        ProjHelper.Info.FP.B.FPType='IG';
        ProjHelper.Info.FP.B.Size=[15.75 23.62]; % Inches. (1) length (2) width (in Motive)
        ProjHelper.Info.FP.B.RefFrame.PosX='W';
        ProjHelper.Info.FP.B.RefFrame.PosY='N';
        ProjHelper.Info.FP.B.RefFrame.PosZ='Down'; % Up or down.
        ProjHelper.Info.FP.B.RefFrame.RHandRule='Yes'; % 'Yes' or 'No' if ref frame follows the R hand rule.
        [refFrameRotMatrix]=ref2cardFrameRotMatrix(ProjHelper.Info.Cardinal,ProjHelper.Info.FP.B.RefFrame);
        ProjHelper.Info.FP.B.RefFrame.RotMatrix2Cardinal=refFrameRotMatrix;
        ProjHelper.Info.FP.C.Position='SW';
        ProjHelper.Info.FP.C.AmpSerial='S039720';
        ProjHelper.Info.FP.C.FPType='IG';
        ProjHelper.Info.FP.C.Size=[15.75 23.62];
        ProjHelper.Info.FP.C.RefFrame.PosX='W';
        ProjHelper.Info.FP.C.RefFrame.PosY='N';
        ProjHelper.Info.FP.C.RefFrame.PosZ='Down'; % Up or down.
        ProjHelper.Info.FP.C.RefFrame.RHandRule='Yes'; % 'Yes' or 'No' if ref frame follows the R hand rule.
        [refFrameRotMatrix]=ref2cardFrameRotMatrix(ProjHelper.Info.Cardinal,ProjHelper.Info.FP.C.RefFrame);
        ProjHelper.Info.FP.C.RefFrame.RotMatrix2Cardinal=refFrameRotMatrix;
        ProjHelper.Info.FP.D.Position='NE';
        ProjHelper.Info.FP.D.AmpSerial='S039802';
        ProjHelper.Info.FP.D.FPType='IG';
        ProjHelper.Info.FP.D.Size=[15.75 23.62];
        ProjHelper.Info.FP.D.RefFrame.PosX='W';
        ProjHelper.Info.FP.D.RefFrame.PosY='N';
        ProjHelper.Info.FP.D.RefFrame.PosZ='Down'; % Up or down.
        ProjHelper.Info.FP.D.RefFrame.RHandRule='Yes'; % 'Yes' or 'No' if ref frame follows the R hand rule.
        [refFrameRotMatrix]=ref2cardFrameRotMatrix(ProjHelper.Info.Cardinal,ProjHelper.Info.FP.D.RefFrame);
        ProjHelper.Info.FP.D.RefFrame.RotMatrix2Cardinal=refFrameRotMatrix;
        ProjHelper.Info.FP.E.Position='SE';
        ProjHelper.Info.FP.E.AmpSerial='S039796';
        ProjHelper.Info.FP.E.FPType='SP'; % Small portable.
        ProjHelper.Info.FP.E.Size=[15.75 23.62];
        ProjHelper.Info.FP.E.RefFrame.PosX='W';
        ProjHelper.Info.FP.E.RefFrame.PosY='N';
        ProjHelper.Info.FP.E.RefFrame.PosZ='Down'; % Up or down.
        ProjHelper.Info.FP.E.RefFrame.RHandRule='Yes'; % 'Yes' or 'No' if ref frame follows the R hand rule.
        [refFrameRotMatrix]=ref2cardFrameRotMatrix(ProjHelper.Info.Cardinal,ProjHelper.Info.FP.E.RefFrame);
        ProjHelper.Info.FP.E.RefFrame.RotMatrix2Cardinal=refFrameRotMatrix;
        
    end
    
    %% Subject attribute logsheet column header names.
    ProjHelper.Info.ColumnNames.Subject.Date='Date';
    ProjHelper.Info.ColumnNames.Subject.Codename='Subject Codename';
    ProjHelper.Info.ColumnNames.Subject.Weight='Body Weight (lb)';
    ProjHelper.Info.ColumnNames.Subject.Height='Height (in)';
    ProjHelper.Info.ColumnNames.Subject.Gender='Gender';
    ProjHelper.Info.ColumnNames.Subject.VisitNumber='Visit Number';
    if any(contains(dataTypes,'FP'))
        ProjHelper.Info.ColumnNames.Subject.FPsUsed='FPs Used'; % Relates Motive order number to FP map letter. e.g. 'A1 B2 C3 D4 E5' OR 'A2 B4 C3 D1 E5' etc. as appropriate.
    end
    
    %% Trial attribute logsheet column header names.
    ProjHelper.Info.ColumnNames.Trial.TrialName='Trial Name/Number'; % If multiple trials per one file, not the same as the file name.
    ProjHelper.Info.ColumnNames.Trial.FileName='Motive Raw File Name'; % This is the file name.
%     ProjHelper.Info.ColumnNames.Trial.RepNumber='Rep Number'; % Within one condition.
%     ProjHelper.Info.ColumnNames.Trial.AltMetrics='Secondary measures';
%     ProjHelper.Info.ColumnNames.Trial.HeightThresholds='Ground Contact Threshold Heights';
    %     ProjHelper.Info.ColumnNames.Trial.AudioFilename='(if Audio Recorded Post-Trial) Audio Filename';
    ProjHelper.Info.ColumnNames.Trial.VisitNumber='Visit Number';
    ProjHelper.Info.ColumnNames.Trial.SideOfInterest='Side Of Interest';
    ProjHelper.Info.ColumnNames.Trial.TaskType='Trial Type/Task';
    ProjHelper.Info.ColumnNames.Trial.CollectionPhase='Collection Phase';
    ProjHelper.Info.ColumnNames.Trial.IsPerfect='Perfect Trial?';
%     ProjHelper.Info.ColumnNames.Trial.BOSRange='BOS Range (incl. buffer)';
%     ProjHelper.Info.ColumnNames.Trial.MOSRange='MOS Range (incl. buffer)';
%     ProjHelper.Info.ColumnNames.Trial.RangeBufferSize='Buffer Size';
%     ProjHelper.Info.ColumnNames.Trial.RangeCalStance='MOS/BOS Area Calibration Stance';
%     ProjHelper.Info.ColumnNames.Trial.TopOfHeadScalingFactors='Unit Vector Scaling Factors';
%     ProjHelper.Info.ColumnNames.Trial.VertErrTolerance='Ground Contact Vertical Error Threshold';
    ProjHelper.Info.ColumnNames.Trial.MotiveInitialFrame='Motive Initial Frame';
    ProjHelper.Info.ColumnNames.Trial.MotiveFinalFrame='Motive Final Frame';
    ProjHelper.Info.ColumnNames.Trial.SubjectComments='Subject Comments (if any)';
    ProjHelper.Info.ColumnNames.Trial.ResearcherComments='Researcher Comments (if any)';
    ProjHelper.Info.ColumnNames.Trial.ZeroEventMotiveFrameNumber='Zero Event Mocap Frame Number'; % If present, great, it's used. If not present, it's not used.
    
elseif(nargin==1) && ischar(markerName) % Called late in importAndFill.m - references segment selector.
    segment=segmentSelector(markerName);
    ProjHelper.colNames=0; dataTypes=0; % Dummy data just to have something to return.
elseif isstruct(markerName) % Input here is the entire data structure.
    
    % NOTE: Marker name selection needs to be project-independent.
    
    % This aggregates data for the GaitEvents_HS_TO function.
    % Gather marker names.
    LASI_Name='LIAS';
    RASI_Name='RIAS';
    LPSI_Name='LIPS';
    RPSI_Name='RIPS';
    LHEE_Name='LFCC';
    RHEE_Name='RFCC';
    LTOE_Name='LDP1';
    RTOE_Name='RDP1';
    numFrames=length(markerName.(LASI_Name));
    % Aggregate those markers' data.
    segment(1,1,1:numFrames,1:3)=markerName.(LASI_Name); % LASI
    segment(1,2,1:numFrames,1:3)=markerName.(RASI_Name); % RASI
    segment(1,3,1:numFrames,1:3)=markerName.(LPSI_Name); % LPSI
    segment(1,4,1:numFrames,1:3)=markerName.(RPSI_Name); % RPSI
    segment(2,1,1:numFrames,1:3)=markerName.(LHEE_Name); % LHEE
    segment(2,2,1:numFrames,1:3)=markerName.(RHEE_Name); % RHEE
    segment(2,3,1:numFrames,1:3)=markerName.(LTOE_Name); % LTOE
    segment(2,4,1:numFrames,1:3)=markerName.(RTOE_Name); % RTOE
    ProjHelper.colNames=0; dataTypes=0; % Dummy data just to have something to return.
    
end
end

function segment = segmentSelector(markerName)
global segMarkerCount;
% Segment list: "Head","LFArm","LHand","LShank","LThigh","LUArm","RFArm","RHand","RShank","RThigh","RUArm","Trunk","Unassigned"
% MARKER NAMES IN EACH SEGMENT INCLUDE TRACKING AND ANATOMIC MARKERS.
inSeg=0;
numSegs=0;

if any(contains({'LAH','RAH','LPH','RPH','CV7','VHTOP'},upper(markerName)))
    segMarkerCount(1)=segMarkerCount(1)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="HEAD";
    inSeg=1;
end
if any(contains({'SJN','SXS','CV7','TV2','TV7','LIAS','RIAS','LIPS','RIPS','LCAJ','RCAJ','LHGT','RHGT'},upper(markerName)))
    segMarkerCount(2)=segMarkerCount(2)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="TRUNK";
    inSeg=1;
end
if any(contains({'LUA','LHLE','LHME','LCAJ','LSHOULDER'},upper(markerName)))
    segMarkerCount(3)=segMarkerCount(3)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="LUARM";
    inSeg=1;
end
if any(contains({'RUA','RHLE','RHME','RCAJ','RSHOULDER'},upper(markerName)))
    segMarkerCount(4)=segMarkerCount(4)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="RUARM";
    inSeg=1;
end
if any(contains({'LHLE','LRSP','LUSP','LHME'},upper(markerName)))
    segMarkerCount(5)=segMarkerCount(5)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="LFARM";
    inSeg=1;
end
if any(contains({'RHLE','RRSP','RUSP','RHME'},upper(markerName)))
    segMarkerCount(6)=segMarkerCount(6)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="RFARM";
    inSeg=1;
end
if any(contains({'LRSP','LUSP','LHM2'},upper(markerName)))
    segMarkerCount(7)=segMarkerCount(7)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="LHAND";
    inSeg=1;
end
if any(contains({'RRSP','RUSP','RHM2'},upper(markerName)))
    segMarkerCount(8)=segMarkerCount(8)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="RHAND";
    inSeg=1;
end
if any(contains({'RFTC','RTH','RFLE','RFME','RTHIGH_3','RTHIGH_4','RTHIGH_5','RHIP'},upper(markerName)))
    segMarkerCount(9)=segMarkerCount(9)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="RTHIGH";
    inSeg=1;
end
if any(contains({'LFTC','LTH','LFLE','LFME','LTHIGH_3','LTHIGH_4','LTHIGH_5','LHIP'},upper(markerName)))
    segMarkerCount(10)=segMarkerCount(10)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="LTHIGH";
    inSeg=1;
end
if any(contains({'RFAX','RSK','RFAL','RTTC','RFME','RTAM'},upper(markerName)))
    segMarkerCount(11)=segMarkerCount(11)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="RSHANK";
    inSeg=1;
end
if any(contains({'LFAX','LSK','LFAL','LTTC','LFME','LTAM'},upper(markerName)))
    segMarkerCount(12)=segMarkerCount(12)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="LSHANK";
    inSeg=1;
end
if any(contains({'LFAL','LFCC','LFM5','LDP1','LFM1','LTAM','LFM2'},upper(markerName)))
    segMarkerCount(13)=segMarkerCount(13)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="LFOOT";
    inSeg=1;
end
if any(contains({'RFAL','RFM5','RDP1','RFM1','RFCC','RTAM','RFM2'},upper(markerName)))
    segMarkerCount(14)=segMarkerCount(14)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="RFOOT";
    inSeg=1;
end
if contains(upper(markerName),'UNLABELED')
    segMarkerCount(15)=segMarkerCount(15)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="UNLABELED";
    inSeg=1;
end
if inSeg==0
    segMarkerCount(16)=segMarkerCount(16)+1;
    numSegs=numSegs+1;
    segment(numSegs,1)="UNASSIGNED";
end

end