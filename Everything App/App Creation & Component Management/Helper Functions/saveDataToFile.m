function []=saveDataToFile(fig,projectStruct,subName,trialName)

%% PURPOSE: SAVE THE CURRENT DATA TO THE APPROPRIATE FILE.
% If background toggle is 1, save data off in the background. If 0, save the data in the serial thread.


projectName=getappdata(fig,'projectName');

if exist('trialName','var') && ~isempty(trialName) % Save trial level
    trialData=projectStruct.(subName).(trialName);
    level='T';
elseif exist('subName','var') && ~isempty(subName) % Save subject level
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
    level='S';
else % Save to project level
    % Exclude subject names fieldnames
    subNames=getappdata(fig,'subjectNames');
    fldNames=fieldnames(projectStruct);
    fldNames=fldNames(~ismember(fldNames,subNames)); % Exclude subject names from field names
    for i=1:length(fldNames)
        projData.(fldNames{i})=projectStruct.(fldNames{i});
    end
    level='P';
end

%% Get file name to save to.
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

dataPath=getappdata(fig,'dataPath');

savePath=[dataPath 'MAT Data Files'];

if isequal(level,'S')
    savePath=[savePath slash subName slash subName '_' projectName];
end

if isequal(level,'T')
    savePath=[savePath slash subName slash trialName '_' subName '_' projectName];
end

if isequal(level,'P')
    savePath=[savePath slash projectName];
end

savePath=[savePath '.mat'];

switch level
    case 'T'
        save(savePath,'trialData','-v6');
    case 'S'
        save(savePath,'subjData','-v6');
    case 'P'
        save(savePath,'projData','-v6');
end
