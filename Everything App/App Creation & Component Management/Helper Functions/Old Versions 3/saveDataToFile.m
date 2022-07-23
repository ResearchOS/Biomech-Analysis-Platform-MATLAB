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