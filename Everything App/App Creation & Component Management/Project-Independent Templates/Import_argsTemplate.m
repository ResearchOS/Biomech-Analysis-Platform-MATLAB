function [ProjHelper,dataTypes]=importMetadataTemplate()

%% PURPOSE: THIS IS THE IMPORTSETTINGS TEMPLATE, INDEPENDENT OF ANY PROJECT.

%% MANDATORY METADATA. DO NOT CHANGE VARIABLE NAMES OR TYPES, ONLY THEIR VALUES. THESE ARE REQUIRED FOR 100% OF PROJECTS.
collectionSite='Zaferiou Lab'; % The physical location/site where the data was collected.
codenameHeader='Subject Codename'; % The column header name for the subject name (aka ID/number/codename) column. Variable name must not change, but its value can.
trialName='Trial Name/Number'; % The column header for the trial name (aka ID/number) column. Variable name must not change, but its value can.
dataTypes=upper({'MOCAP','FP'}); % Which data types are to be imported. This should be all caps.

%% DATA TYPE-SPECIFIC MANDATORY METADATA. DO NOT CHANGE VARIABLE NAMES OR TYPES, ONLY THEIR VALUES. THESE ARE REQUIRED FOR 100% OF PROJECTS USING THESE DATA TYPES.
if contains(dataTypes,'FP')
    fpsUsed='FPs Used'; % Column header name for mapping the force plate numbers in data collection software to letters in a user-created sequence. Variable name must not change, but its value can.
end
if contains(dataTypes,'MOCAP')
    % Need to specify the marker set for each subject, probably in a separate file.
    
    % Need to specify which markers are associated with which segments and for what purpose? Or should this be done in a different location?
    
    % Need to specify EITHER the orientations of the mocap and cardinal coordinate system using cardinal directions ('N', 'E', 'S', 'W') OR allow the
    % user to directly specify a rotation matrix from one to the other.
    
end

%% DATA TYPE-SPECIFIC METADATA REQUIRED FOR CERTAIN ANALYSES. DO NOT CHANGE VARIABLE NAMES OR TYPES, ONLY THEIR VALUES. THESE ARE NOT REQUIRED FOR ALL PROJECTS, BUT FOR SOME ANALYSES THEY ARE MANDATORY.
% Format: ProjHelper.Info.(dataType).(metadataName)=metadataValue;
if contains(dataTypes,'MOCAP')
    ProjHelper.Info.MOCAP.SegmentParameters='Dumas2007';
end
if contains(dataTypes,'FP')
    
end

%% OPTIONAL METADATA FROM THE LOGSHEET.
% Subject level: ProjHelper.Info.ColumnNames.Subject.(subjectMetadata)=subjectColumnHeader;
ProjHelper.Info.ColumnNames.Subject.Date='Date';
ProjHelper.Info.ColumnNames.Subject.Weight='Body Weight (lb)';
ProjHelper.Info.ColumnNames.Subject.Height='Height (in)';
ProjHelper.Info.ColumnNames.Subject.Gender='Gender';
ProjHelper.Info.ColumnNames.Subject.Age='Age';
ProjHelper.Info.ColumnNames.Subject.VisitNumber='Visit Number';

% Trial level: ProjHelper.Info.ColumnNames.Trial.(trialMetadata)=trialColumnHeader;
ProjHelper.Info.ColumnNames.Trial.LateCueFrame='Late Cue Frame';
ProjHelper.Info.ColumnNames.Trial.VisitNumber='Visit Number';
ProjHelper.Info.ColumnNames.Trial.SideOfInterest='Side Of Interest';
ProjHelper.Info.ColumnNames.Trial.TaskType='Trial Type/Task';
ProjHelper.Info.ColumnNames.Trial.CollectionPhase='Collection Phase';
ProjHelper.Info.ColumnNames.Trial.IsPerfect='Perfect Trial?';
ProjHelper.Info.ColumnNames.Trial.StartFrame='Motive Initial Frame';
ProjHelper.Info.ColumnNames.Trial.EndFrame='Motive Final Frame';
ProjHelper.Info.ColumnNames.Trial.SubjectComments='Subject Comments (if any)';
ProjHelper.Info.ColumnNames.Trial.ResearcherComments='Researcher Comments (if any)';





ProjHelper.Info.ColumnNames.Subject.Codename='Subject Codename';
ProjHelper.Info.ColumnNames.Trial.TrialName=trialName; % Do not change this line at all.

%% Trial attribute logsheet column header names.


if nargin==1 && iscell(subjectListInStruct) % Called by getValidTrialNames with subjectListInStruct input.
        
    [ProjHelper]=feval([ProjHelper.Info.SegmentParameters 'ParamsMetadata'],ProjHelper); % Get the metadata for the segment parameters model.
    
    ProjHelper.Info.DataCollectionSite=location;
    ProjHelper.Info.SubjectList=subjectListInStruct; % Provided by getValidTrialNames
    
    % Motion capture data = 'mocap'
    % EMG data = 'EMG'
    % IMU data = 'IMU'
    % Forceplate data = 'FP'
    %         dataTypes={'MOCAP'}; % Cell array containing chars.
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
        virtualMarkerNames=sort({'LHIP';'RHIP';'VHTOP';'CJC';'LJC';'LEJC';'REJC';'LSJC';'RSJC';'LWJC';'RWJC';'LKJC';'RKJC';'LAJC';'RAJC'}); % Marker names for data to be placed into static calibration "reference" trial.
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
            if isequal(subjectListInStruct{i},"06_Berlin") || isequal(subjectListInStruct{i},"07_Oslo") % Oslo won't be analyzed due to poor tracking.
                ProjHelper.Info.Mocap.Subject(i).AddTrackingMarkerList=sort({'LTHIGH_4';'LTHIGH_5';'RTHIGH_4';'RTHIGH_5'});
                %                 ProjHelper.Info.Mocap(i).AddAnatMarkerList=sort({}); % Not used for now!
            elseif isequal(subjectListInStruct{i},"09_Boston") || isequal(subjectListInStruct{i},"10_Chicago") || isequal(subjectListInStruct{i},"11_Seattle") || ...
                    isequal(subjectListInStruct{i},"12_London") || isequal(subjectListInStruct{i},"13_Paris")
                ProjHelper.Info.Mocap.Subject(i).AddTrackingMarkerList=sort({'LTHIGH_4';'LTHIGH_5';'RTHIGH_4';'RTHIGH_5';'LUARM_4';'LUARM_5';'RUARM_4';'RUARM_5';'LFARM_1';'RFARM_1';'LHAND_4';'RHAND_4'});
            else % This is the default, with no additional markers beyond the core tracking markers.
                ProjHelper.Info.Mocap.Subject(i).AddTrackingMarkerList=sort({});
            end
            ProjHelper.Info.Mocap.Subject(i).TrackingMarkerList=sort(vertcat(coreRefTrackingMarkerNames,ProjHelper.Info.Mocap.Subject(i).AddTrackingMarkerList));
            %             ProjHelper.Info.Mocap.Subject(i).AnatMarkerList=sort(vertcat(coreRefAnatMarkerNames,ProjHelper.Info.Mocap.Subject(i).AddAnatMarkerList));
        end
        ProjHelper.Info.Mocap.AnatMarkerList=coreRefAnatMarkerNames;
        ProjHelper.Info.Mocap.BOSMarkerNames=bosMarkerNames;
        % Segment list helps with properly allocating the marker names to their segments.
        ProjHelper.Info.Mocap.SegmentList=upper(sort(["Head","LFArm","LFoot","LHand","LShank","LThigh","LUArm","RFArm","RFoot","RHand","RShank","RThigh","RUArm","Torso","Pelvis","Unassigned","Unlabeled"])); % Includes Unassigned.
        
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
    
end