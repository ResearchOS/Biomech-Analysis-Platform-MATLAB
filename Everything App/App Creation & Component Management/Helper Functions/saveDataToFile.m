function []=saveDataToFile(fig,projectStruct,subName,trialName,saveLevels)

%% PURPOSE: SAVE THE CURRENT DATA TO THE APPROPRIATE FILE.
% Inputs:
% fig: The gui figure object (handle)
% projectStruct: The entire project's data (struct)
% subName: The current subject's name, if applicable (char)
% trialName: The current trial's name, if applicable (char)
% saveLevels: Which type of data to save, as only the new/modified data should be saved (saveLevels)

projectName=getappdata(fig,'projectName');

if ismember('Trial',saveLevels) % Save trial level
    trialData=projectStruct.(subName).(trialName);
end

if ismember('Subjct',saveLevels)
    % Exclude trial names fieldnames
    trialNameColNum=getappdata(fig,'trialNameColumnNum');
    subjNameColNum=getappdata(fig,'subjectCodenameColumnNum');
    logVar=evalin('base','logVar');
    rowNums=ismember(logVar(:,subjNameColNum),subName); % The row numbers for the current subject
    trialNames=logVars(rowNums,trialNameColNum); % The trial names for the current subject
    fldNames=fieldnames(projectStruct.(subName));
    fldNames=fldNames(~ismember(fldNames,trialNames)); % Exclude trial names from field names
    for i=1:length(fldNames)
        subjData.(fldNames{i})=projectStruct.(subName).(fldNames{i});
    end
end

if ismember('Project',saveLevels) % Save to project level
    % Exclude subject names fieldnames
    subNames=getappdata(fig,'subjectNames');
    fldNames=fieldnames(projectStruct);
    fldNames=fldNames(~ismember(fldNames,subNames)); % Exclude subject names from field names
    for i=1:length(fldNames)
        projData.(fldNames{i})=projectStruct.(fldNames{i});
    end
end

%% Get file name to save to.
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

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
