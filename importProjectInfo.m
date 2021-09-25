function projectStruct=importProjectInfo(projectStruct,ProjHelper,projectPath,projectName,logsheetPath,flags)

%% PURPOSE: RETURN THE PROJECT-LEVEL METADATA
% Inputs:
% projectStruct: All subjects all data (struct)
% ProjHelper: Output from importSettings (struct)
% projectPath: Full path to the project-specific processing folder containg .m files & Subject Data (char)
% projectName: Suffix of the importSettings file (char)
% logsheetPath: Full path to the logsheet (char)
% flags: Boolean flags containing processing settings

% Outputs:
% projectStruct: Contains all project-level metadata (struct)

listing=dir('*.mat');
fileNames={};
for i=1:length(listing)
    fileNames{i}=listing(i).name;
end
% Previous projectMetadata .mat file exists, and not updating metadata.
if any(contains(fileNames,projectName)) && flags.UpdateMetadata==0 && flags.Redo==0
    fileIdx=contains(fileNames,projectName);
    projectStruct=load(fileNames{fileIdx});
    subStructName=fieldnames(projectStruct);
    projectStruct=projectStruct.(subStructName{1}); % Ensure continuity of naming
    projectStruct.Info.Flags=flags; % Ensure prior flags don't overwrite current ones.
    assignin('base','projectStruct',projectStruct);
    return;
end

% Only runs if not loading previous projectStruct info.
projectStruct.Info.ProjectName=projectName; % Store the project name.
projectStruct.Info.ProjectPath=projectPath;
projectStruct.Info.LogsheetPath=logsheetPath;
projectStruct.Info.ImportSettingsPath=[projectPath 'importSettings' projectName];
projectStruct.Info.CollectionSite=ProjHelper.Info.DataCollectionSite;
projectStruct.Info.DataTypes=ProjHelper.Info.DataTypes;
projectStruct.Info.SubjectNames=ProjHelper.Info.SubjectList;
projectStruct.Info.PhaseDefsThresholdTaskName=ProjHelper.Info.PhaseDefsThresholdTaskName; % This is the task to use for developing phases of the turn.
projectStruct.Info.TaskOfIntName=ProjHelper.Info.TaskOfIntName; % This is the turning while walking task.
projectStruct.Info.StaticCalTaskName=ProjHelper.Info.StaticCalTaskName; % Task used to store person's height, weight, & head model data.
projectStruct.Info.DynamicCalTaskName=ProjHelper.Info.DynamicCalTaskName; % Generates 3D joint centers & axes.
projectStruct.Info.DynamicCalJoints=ProjHelper.Info.DynamicCalJoints; % Joints to create in dynamic calibration.
projectStruct.Info.DynamicCalJointsSegments=ProjHelper.Info.DynamicCalJointsSegments; % Segment names used to generate the dynamic calibration joints.
projectStruct.Info.StaticCalJoints=ProjHelper.Info.StaticCalJoints; % Joints to create in static calibration.
projectStruct.Info.StaticCalJointsSegments=ProjHelper.Info.StaticCalJointsSegments; % Segment names used to generate the static calibration joints.
projectStruct.Info.MaxTBCMHoldDur=ProjHelper.Info.MaxHoldDur; % Maximum NUMBER OF FRAMES to hold the TBCM value for.
projectStruct.Info.RefFrames.Cardinal=ProjHelper.Info.Cardinal; % Cardinal reference frame.
projectStruct.Info.SegmentParameters=ProjHelper.Info.SegmentParameters; % Which segment parameters were used.
if any(contains(ProjHelper.Info.DataTypes,'MOCAP'))
    projectStruct.Info.RefFrames.Mocap=ProjHelper.Info.Mocap.RefFrame;
    projectStruct.Info.Mocap.SegmentList=sort(ProjHelper.Info.Mocap.SegmentList); % Already sorted alphabetically, but can't hurt to do it twice.
    projectStruct.Info.Mocap.AnatMarkerList=ProjHelper.Info.Mocap.AnatMarkerList; % Anatomical/calibration marker names, removed after static/dynamic trials.
    projectStruct.Info.Mocap.BOSMarkerNames=ProjHelper.Info.Mocap.BOSMarkerNames; % Markers that could comprise the BOS.
    projectStruct.Info.Mocap.VirtualMarkerNames=ProjHelper.Info.Mocap.VirtualMarkerNames;
    projectStruct.Info.Mocap.RigidBodyMarkerNames=ProjHelper.Info.Mocap.RigidBodyMarkerNames;
    projectStruct.Info.Mocap.RigidBodyNames=ProjHelper.Info.Mocap.RigidBodyNames;
end
if any(contains(ProjHelper.Info.DataTypes,'FP'))
    projectStruct.Info.FP.COPFzThreshold=ProjHelper.Info.FP.COPFzThreshold;
end

assignin('base','projectStruct',projectStruct);
save(['Metadata' projectName '.mat'],'projectStruct','-v6');