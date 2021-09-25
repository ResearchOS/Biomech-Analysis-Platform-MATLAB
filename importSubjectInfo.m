function subStruct=importSubjectInfo(logsheet,ProjHelper,subName,projectName,flags)

%% PURPOSE: RETURN THE SUBJECT-LEVEL METADATA
% Inputs:
% logsheet: The logsheet variable (2D cell array)
% ProjHelper: Output from importSettings (struct)
% subName: The subject's name. (char)
% projectName: The name of the current project (char)
% flags: Booleans to indicate settings (struct)

% Outputs:
% subStruct: Contains all subject-level metadata (struct)

listing=dir('*.mat');
fileNames={};
for i=1:length(listing)
    fileNames{i}=listing(i).name;
end
% Previous projectMetadata .mat file exists, and not updating metadata.
if any(contains(fileNames,projectName)) && any(contains(fileNames,subName)) && flags.UpdateMetadata==0 && flags.Redo==0
    fileIdx=contains(fileNames,projectName);
    subStruct=load(fileNames{fileIdx});
    subStructName=fieldnames(subStruct);
    subStruct=subStruct.(subStructName{1}); % Ensure continuity of naming
    return;
end

subStruct.Info.Codename=subName;
dataTypes=upper(ProjHelper.Info.DataTypes);

if any(contains(dataTypes,'MOCAP'))
    % NOW SUBJECT-SPECIFIC, because different auxiliary markers for different subjects.
    subNum=find(contains(ProjHelper.Info.SubjectList,subName));
    subStruct.Info.Mocap.TrackingMarkerList=ProjHelper.Info.Mocap.Subject(subNum).TrackingMarkerList; % Tracking markers, kept on throughout the entire experiment.
end

% Store subject info.
[~,subIDCol]=find(strcmp(logsheet(1,:),ProjHelper.Info.ColumnNames.Subject.Codename),1);
subRow=find(contains(logsheet(:,subIDCol),subName),1,'first'); % First row of the subject.
subAttrs=fieldnames(ProjHelper.Info.ColumnNames.Subject);
for i=1:length(subAttrs) % Populate subject-level info fields.
    headerName=ProjHelper.Info.ColumnNames.Subject.(subAttrs{i});
    subStruct.Info.(subAttrs{i})=logsheet(subRow,strcmp(logsheet(1,:),headerName));
    if iscell(subStruct.Info.(subAttrs{i})) % Ensure it's not a cell.
        subStruct.Info.(subAttrs{i})=subStruct.Info.(subAttrs{i}){1};
    end
end

% Segment parameter-related info.
if isfield(ProjHelper.Info.Mocap,'SegmentOrigins')
    subStruct.Info.Mocap.Segments.SegmentOrigins=ProjHelper.Info.Mocap.SegmentOrigins;
end
% Check that segment params are used (from subStruct)
if isfield(ProjHelper.Info,'SegmentParameters')
    if isequal(subStruct.Info.Gender,'m')
        subStruct.Info.Mocap.Segments.COMPercLoc=ProjHelper.Info.Mocap.Male.COMPercLoc;
        subStruct.Info.Mocap.Segments.SegmentPercWeight=ProjHelper.Info.Mocap.Male.SegWeights; % Percent of body mass for each segment.
        subStruct.Info.Mocap.Segments.TensorOfInertiaScale=ProjHelper.Info.Mocap.Male.TensorOfInertiaScale;
    elseif isequal(subStruct.Info.Gender,'f')
        subStruct.Info.Mocap.Segments.COMPercLoc=ProjHelper.Info.Mocap.Female.COMPercLoc;
        subStruct.Info.Mocap.Segments.SegmentPercWeight=ProjHelper.Info.Mocap.Female.SegWeights;
        subStruct.Info.Mocap.Segments.TensorOfInertiaScale=ProjHelper.Info.Mocap.Male.TensorOfInertiaScale;
    end
end

save(['Metadata ' subName ' ' projectName '.mat'],'subStruct','-v6');