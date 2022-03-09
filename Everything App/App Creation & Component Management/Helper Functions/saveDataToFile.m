function []=saveDataToFile(fig,projectStruct,subName,trialName,saveLevels,savePathsPerLevel)

%% PURPOSE: SAVE THE CURRENT DATA TO THE APPROPRIATE FILE.
% Inputs:
% fig: The gui figure object (handle)
% projectStruct: The entire project's data (struct)
% subName: The current subject's name, if applicable (char)
% trialName: The current trial's name, if applicable (char)
% saveLevels: Which type of data to save, as only the new/modified data should be saved (saveLevels)

%% Needs to load data from the existing file, then add the new data to the struct, then save the modified struct to file.

projectName=getappdata(fig,'projectName');

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

%% Trial level save prep
if ismember('Trial',saveLevels) % Save trial level
    % Load trial data.
    savePaths=savePathsPerLevel.Trial.Paths;
    savePathsFull=savePathsPerLevel.Trial.FullPaths;
    trialMatPath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
    if exist(trialMatPath,'file')==2
        trialData=load([getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat']);
        fldNames=fieldnames(trialData);
        assert(length(fldNames)==1);
        trialData=trialData.(fldNames{1}); % This trial's data from file.        
    end

    for i=1:length(savePaths)
        eval(['trialData.' savePaths{i} '=' savePathsFull{i} ';']);
    end
end

%% Subject level save prep
if ismember('Subject',saveLevels)
    % Exclude trial names fieldnames
    savePaths=savePathsPerLevel.Subject.Paths;
    savePathsFull=savePathsPerLevel.Subject.FullPaths;
    subjMatPath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];
    if exist(subjMatPath,'file')==2
        subjData=load(subjMatPath);
        fldNames=fieldnames(subjData);
        assert(length(fldNames)==1);
        subjData=subjData.(fldNames{1}); % This subject's data from file.
    end

    for i=1:length(savePaths)
        eval(['subjData.' savePaths{i} '=' savePathsFull{i} ';']);
    end

%     trialNameColNum=getappdata(fig,'trialNameColumnNum');
%     subjNameColNum=getappdata(fig,'subjectCodenameColumnNum');
%     logVar=evalin('base','logVar');
%     rowNums=ismember(logVar(:,subjNameColNum),subName); % The row numbers for the current subject
%     trialNames=logVars(rowNums,trialNameColNum); % The trial names for the current subject
%     fldNames=fieldnames(projectStruct.(subName));
%     fldNames=fldNames(~ismember(fldNames,trialNames)); % Exclude trial names from field names
%     for i=1:length(fldNames)
%         subjData.(fldNames{i})=projectStruct.(subName).(fldNames{i});
%     end
end

%% Project level save prep
if ismember('Project',saveLevels) % Save to project level
    savePaths=savePathsPerLevel.Project.Paths;
    savePathsFull=savePathsPerLevel.Project.FullPaths;
    projMatPath=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];
    if exist(projMatPath,'file')==2
        projData=load(projMatPath);
        fldNames=fieldnames(projData);
        assert(length(fldNames)==1);
        projData=projData.(fldNames{1}); % This subject's data from file.
    end

    for i=1:length(savePaths)
        eval(['projData.' savePaths{i} '=' savePathsFull{i} ';']);
    end

    % Exclude subject names fieldnames
%     subNames=getappdata(fig,'subjectNames');
%     fldNames=fieldnames(projectStruct);
%     fldNames=fldNames(~ismember(fldNames,subNames)); % Exclude subject names from field names
%     for i=1:length(fldNames)
%         projData.(fldNames{i})=projectStruct.(fldNames{i});
%     end
end

%% Get file name to save to.

dataPath=getappdata(fig,'dataPath');

savePathRoot=[dataPath 'MAT Data Files'];

if ismember('Project',saveLevels)
    savePath=[savePathRoot slash projectName '.mat'];
    save(savePath,'projData','-v6');
end

if ismember('Subject',saveLevels)
    savePath=[savePathRoot slash subName slash subName '_' projectName '.mat'];
    save(savePath,'subjData','-v6');
end

if ismember('Trial',saveLevels)
    savePath=[savePathRoot slash subName slash trialName '_' subName '_' projectName '.mat'];
    save(savePath,'trialData','-v6');
end
