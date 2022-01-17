function []=longTermSave(argPaths,dataPath,levels,projectName)

%% PURPOSE: MOVE DATA FROM TEMPORARY FILES TO LONG-TERM SAVE FILES IN THE BACKGROUND, TO MINIMIZE SAVE TIME AND DISRUPTION TO WORKFLOW.
% Inputs:
% argPaths: The full file paths to the temporary arguments folder (cell array of chars)
% dataPath: The data path set in the GUI (char)
% levels: The level to save the data to (cell array of chars)
% projectName: The current project name

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

rootSavePath=[dataPath 'MAT Data Files'];

if any(ismember(levels,{'P'}))    
    projPath=[rootSavePath slash projectName '.mat'];
    projData=load(projPath); % Load project level data
end

% Load the subject/trial level data, as necessary
if any(ismember(levels,{'S','T'}))
    
    % Check which subject and/or trial to load
    for i=1:length(argPaths)
        
        currPath=argPaths{i};
        level=levels{i};
        [~,name]=fileparts(currPath);
        splitName=strsplit(name,'.');
        
        if isequal(level,'S')
            subName=splitName{2};
        elseif isequal(level,'T')
            subName=splitName{2};
            trialName=splitName{3};
            break; % No need to keep checking when subName and trialName were already assigned.
        end
        
    end
    
    % Load all of the existing data
    if any(ismember(levels,{'S'}))
        subjPath=[rootSavePath slash subName slash subName '_' projectName '.mat'];
        subjData=load(subjPath);
    end
    
    if any(ismember(levels,{'T'}))
        trialPath=[rootSavePath slash subName slash trialName '_' subName '_' projectName '.mat'];
        trialData=load(trialPath);
    end
    
end

% Store the new data into the existing data
for i=1:length(argPaths)
    
    % Load the new data
    newArg=load(argPaths{i});
    level=levels{i};
    [~,structPath]=fileparts(argPaths{i}); % The location within the struct of the current arg.
    dotIdx=strfind(newPath,'.');
    
    % Get the truncated data path
    switch level
        case 'P'
            newPath=['projData' structPath(dotIdx(1):end)]; % The truncated path so that it can be placed into projData
        case 'S'
            newPath=['subjData' structPath(dotIdx(2):end)]; % The truncated path so that it can be placed into subjData
        case 'T'
            newPath=['trialData' structPath(dotIdx(3):end)]; % The truncated path so that it can be placed into subjData
    end
    
    eval([newPath '=' newArg ';']); % Store the new data into the existing data. No need to assign it to base workspace, that was already done.
    
end

%% Save the data back to the file
if any(ismember(levels,{'P'}))
    save(projPath,'projData','-v6');
end
if any(ismember(levels,{'S'}))
    save(subjPath','subjData','-v6');
end

if any(ismember(levels,{'T'}))
    save(trialPath,'trialData','-v6');
end