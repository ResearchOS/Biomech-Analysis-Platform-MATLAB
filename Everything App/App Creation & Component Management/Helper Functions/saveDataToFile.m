function []=saveDataToFile(fig,projectStruct,savePathsPerLevel)

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

saveLevels=fieldnames(savePathsPerLevel);

% Loop over each level. First, sort each path to ensure files are each loaded only one time.
for i=1:length(saveLevels)
    currLevel=saveLevels{i};

    savePathsPerLevel.(currLevel).Paths=sort(unique(savePathsPerLevel.(currLevel).Paths));
    currPaths=savePathsPerLevel.(currLevel).Paths; % The current level's paths

    prevMatFilePath=''; % Clear the previous when transitioning between levels.

    for j=1:length(currPaths) % Iterate over each path.
        pathSplit=strsplit(currPaths{j},'.');
        dotIdx=strfind(currPaths{j},'.');

        switch currLevel % Load the appropriate file
            case 'Trial'
                trialName=pathSplit{3};
                subName=pathSplit{2};
                matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
%                 varLevelDataName='trialData';
                dotNum=3;
            case 'Subject'
                subName=pathSplit{2};
                matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];
%                 varLevelDataName='subjData';
                dotNum=2;
            case 'Project'
                matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];
%                 varLevelDataName='projData';
                dotNum=1;
        end        

        if ~isequal(prevMatFilePath,matFilePath) % Save off a mat file and load the new mat file if it exists.

            if ~isempty(prevMatFilePath) % Save off the previous file.
                eval(['save(''' prevMatFilePath ''',''data'',' '''-v6''' ');']);
            end

            % Load the new file.
            if exist(matFilePath,'file')==2
                matFile=load(matFilePath);
                fldNames=fieldnames(matFile);
                assert(length(fldNames)==1);
                data=matFile.(fldNames{1});
            else
                clear data;
            end

        end

        % Put the new data into the loaded MAT file.
        eval(['data.' currPaths{j}(dotIdx(dotNum)+1:end) '=' currPaths{j} ';']);        

        prevMatFilePath=matFilePath;

    end

    % Save off the final file.
    if ~isempty(currPaths)
        eval(['save(''' matFilePath ''',''data'',' '''-v6''' ');']);
    end

end

handles=getappdata(fig,'handles');
groupName=handles.ProcessRun.runGroupNameDropDown.Value; % Only for one group at a time

disp(['Finished saving all data from processing group: ' groupName]);










% %% Trial level save prep
% if ismember('Trial',saveLevels) % Save trial level
%     % Load trial data.
%     savePaths=savePathsPerLevel.Trial.Paths;
% %     savePathsFull=savePathsPerLevel.Trial.FullPaths;
%     trialMatPath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
%     if exist(trialMatPath,'file')==2
%         trialData=load([getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat']);
%         fldNames=fieldnames(trialData);
%         assert(length(fldNames)==1);
%         trialData=trialData.(fldNames{1}); % This trial's data from file.        
%     end
% 
%     for i=1:length(savePaths)
%         eval(['trialData.' savePaths{i} '=' savePaths{i} ';']);
%     end
% end
% 
% %% Subject level save prep
% if ismember('Subject',saveLevels)
%     % Exclude trial names fieldnames
%     savePaths=savePathsPerLevel.Subject.Paths;
% %     savePathsFull=savePathsPerLevel.Subject.FullPaths;
%     subjMatPath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];
%     if exist(subjMatPath,'file')==2
%         subjData=load(subjMatPath);
%         fldNames=fieldnames(subjData);
%         assert(length(fldNames)==1);
%         subjData=subjData.(fldNames{1}); % This subject's data from file.
%     end
% 
%     for i=1:length(savePaths)
%         eval(['subjData.' savePaths{i} '=' savePaths{i} ';']);
%     end
% 
% %     trialNameColNum=getappdata(fig,'trialNameColumnNum');
% %     subjNameColNum=getappdata(fig,'subjectCodenameColumnNum');
% %     logVar=evalin('base','logVar');
% %     rowNums=ismember(logVar(:,subjNameColNum),subName); % The row numbers for the current subject
% %     trialNames=logVars(rowNums,trialNameColNum); % The trial names for the current subject
% %     fldNames=fieldnames(projectStruct.(subName));
% %     fldNames=fldNames(~ismember(fldNames,trialNames)); % Exclude trial names from field names
% %     for i=1:length(fldNames)
% %         subjData.(fldNames{i})=projectStruct.(subName).(fldNames{i});
% %     end
% end
% 
% %% Project level save prep
% if ismember('Project',saveLevels) % Save to project level
%     savePaths=savePathsPerLevel.Project.Paths;
%     savePathsFull=savePathsPerLevel.Project.FullPaths;
%     projMatPath=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];
%     if exist(projMatPath,'file')==2
%         projData=load(projMatPath);
%         fldNames=fieldnames(projData);
%         assert(length(fldNames)==1);
%         projData=projData.(fldNames{1}); % This subject's data from file.
%     end
% 
%     for i=1:length(savePaths)
%         eval(['projData.' savePaths{i} '=' savePathsFull{i} ';']);
%     end
% 
%     % Exclude subject names fieldnames
% %     subNames=getappdata(fig,'subjectNames');
% %     fldNames=fieldnames(projectStruct);
% %     fldNames=fldNames(~ismember(fldNames,subNames)); % Exclude subject names from field names
% %     for i=1:length(fldNames)
% %         projData.(fldNames{i})=projectStruct.(fldNames{i});
% %     end
% end
% 
% %% Get file name to save to.
% 
% dataPath=getappdata(fig,'dataPath');
% 
% savePathRoot=[dataPath 'MAT Data Files'];
% 
% if ismember('Project',saveLevels)
%     savePath=[savePathRoot slash projectName '.mat'];
%     save(savePath,'projData','-v6');
% end
% 
% if ismember('Subject',saveLevels)
%     savePath=[savePathRoot slash subName slash subName '_' projectName '.mat'];
%     save(savePath,'subjData','-v6');
% end
% 
% if ismember('Trial',saveLevels)
%     savePath=[savePathRoot slash subName slash trialName '_' subName '_' projectName '.mat'];
%     save(savePath,'trialData','-v6');
% end
