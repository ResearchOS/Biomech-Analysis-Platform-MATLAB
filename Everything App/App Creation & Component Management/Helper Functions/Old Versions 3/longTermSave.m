function []=longTermSave()

%% PURPOSE: MOVE DATA FROM TEMPORARY FILES TO LONG-TERM SAVE FILES IN THE BACKGROUND, TO MINIMIZE SAVE TIME AND DISRUPTION TO WORKFLOW.
% Inputs:
% argPaths: The full file paths to the temporary arguments folder (cell array of chars)
% dataPath: The data path set in the GUI (char)
% levels: The level to save the data to (cell array of chars)
% projectName: The current project name

if ismac==1
    slash='/';
    load(['/Users/' getenv('username') '/Downloads/TempSaveNames.mat']);
    delete(['/Users/' getenv('username') '/Downloads/TempSaveNames.mat']);
elseif ispc==1
    slash='\';
    load(['C:\Users\' getenv('username') '\Documents\TempSaveNames.mat']);
    delete(['C:\Users\' getenv('username') '\Documents\TempSaveNames.mat']);
end

rootSavePath=[dataPath 'MAT Data Files'];

if any(ismember(level,{'P'}))    
    projPath=[rootSavePath slash projectName '.mat'];
    if exist(projPath,'file')==2
        projData=load(projPath); % Load project level data
    end
end

% Load the subject/trial level data, as necessary
if any(ismember(level,{'S','T'}))
    
    % Check which subject and/or trial to load
    for i=1:length(tempSaveNames)
        
        currPath=tempSaveNames{i};
        currLevel=level{i};
        [~,name]=fileparts(currPath);
        splitName=strsplit(name,'.');
        
        if isequal(currLevel,'S')
            subName=splitName{2};
        elseif isequal(currLevel,'T')
            subName=splitName{2};
            trialName=splitName{3};
            break; % No need to keep checking when subName and trialName were already assigned.
        end
        
    end
    
    % Load all of the existing data
    if any(ismember(level,{'S'}))
        subjPath=[rootSavePath slash subName slash subName '_' projectName '.mat'];
        if exist(subjPath,'file')==2
            subjData=load(subjPath);
        end
    end
    
    if any(ismember(level,{'T'}))
        trialPath=[rootSavePath slash subName slash trialName '_' subName '_' projectName '.mat'];
        if exist(trialPath,'file')==2
            trialData=load(trialPath);
        end
    end
    
end

% Store the new data into the existing data
for i=1:length(tempSaveNames)
    
    % Load the new data
    load(tempSaveNames{i});
    currLevel=level{i};
    [~,structPath]=fileparts(tempSaveNames{i}); % The location within the struct of the current arg.
    dotIdx=strfind(structPath,'.');
    
    % Get the truncated data path
    switch currLevel
        case 'P'
            newPath=['projData' structPath(dotIdx(1):end)]; % The truncated path so that it can be placed into projData
        case 'S'
            newPath=['subjData' structPath(dotIdx(2):end)]; % The truncated path so that it can be placed into subjData
        case 'T'
            newPath=['trialData' structPath(dotIdx(3):end)]; % The truncated path so that it can be placed into subjData
    end
    
    eval([newPath '=tempVar;']); % Store the new data into the existing data. No need to assign it to base workspace, that was already done.
    
end

%% Save the data back to the file
if any(ismember(level,{'P'}))
    save(projPath,'projData','-v6');
end
if any(ismember(level,{'S'}))
    save(subjPath','subjData','-v6');
end

if any(ismember(level,{'T'}))
    save(trialPath,'trialData','-v6');
end

%% Delete the temporary files
for i=1:length(tempSaveNames)
    
    delete(tempSaveNames{i}); % Delete the mat file with the temporary data
    [~,name]=fileparts(tempSaveNames{i});
    disp(['Saved to long term storage: ' name]);
    
end

% quit; % QUITS OUT OF THIS MATLAB INSTANCE