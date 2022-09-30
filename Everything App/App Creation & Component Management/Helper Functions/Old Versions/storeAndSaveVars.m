function storeAndSaveVars(dataStruct,level,fcnOutputs,subName,trialName)

%% PURPOSE: STORE VARIABLES TO THE PROJECTSTRUCT AND SAVE DATA TO TEMPORARY FILES, AND RUN BACKGROUND PROCESS TO SAVE THE TEMPORARY FILES TO THE ACTUAL FILES.
% Inputs:
% dataStruct: All of the data to save (struct)
% level: Whether the dataStruct is project, subject, or trial level data (char)
% fcnOutputs: Contains all output argument structure paths (struct of cell array of chars)
% subName: Subject name. Used if storing at the subject or trial level (char)
% trialName: Trial name. Used if storing at the trial level (char)

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% Get the fig from the base workspace
fig=evalin('base','gui;');

dataPath=getappdata(fig,'dataPath'); % Top level folder path where the data is stored.
projectName=getappdata(fig,'projectName'); % Project name

%% Get the current level's function outputs
if isfield(fcnOutputs,level)
    fcnOutputs=fcnOutputs.(level);
end

%% Store data to projectStruct
% Only store modified data
for i=1:length(fcnOutputs)
    
    assignin('base','currData',eval(fcnOutputs{i})); % Assign the current output variable to the base workspace.
    if isnumeric(eval(fcnOutputs{i}))
        evalin('base','currData=single(currData);'); % Convert data to be singles
    end
    
    if isequal(level,'P')
        fcnOutputsFullPaths=['projectStruct.' fcnOutputs{i}(12:end)]; % Replace the dataStruct part of the path with projectStruct
    elseif isequal(level,'S')
        fcnOutputsFullPaths=['projectStruct.' subName '.' fcnOutputs{i}(12:end)]; % Replace the dataStruct part of the path with projectStruct.(subName)
    elseif isequal(level,'T')
        fcnOutputsFullPaths=['projectStruct.' subName '.' trialName '.' fcnOutputs{i}(12:end)]; % Replace the dataStruct part of the path with projectStruct.(subName)
    end
    
    assignin('base','currDataPath',fcnOutputsFullPaths); % Assign the projectStruct path to the base workspace.
    evalin('base','eval(''currDataPath=currData;'''); % Store the data to the appropriate place in the projectStruct.
    
end

%% Save data to file
% TOGGLE:
% IF CHECKBOX CHECKED TO SAVE ALL DATA OF ONE LEVEL AT THE SAME TIME, THEN DO THAT
% IF CHECKBOX UNCHECKED, SAVE ONLY THE MODIFIED DATA TO A TEMPORARY FILE, THEN IN THE BACKGROUND PUSH THAT TEMPORARY DATA INTO THE PERMANENT STORAGE.
% Save the modified data to a temporary file, then use the Background Pool to save that data to the permanent files in the background.
saveModified=0; % Placeholder until the Settings checkbox is written.
if saveModified==0 % Save all data at this level to the file
    switch level
        case 'P' % Save project data
            savePath=[dataPath 'MAT Data Files' slash 'projectData_' projectName '.mat'];
        case 'S' % Save subject data
            savePath=[dataPath 'MAT Data Files' slash subName slash 'subjectData_' projectName '_' subName '.mat'];
        case 'T' % Save trial data
            savePath=[dataPath 'MAT Data Files' slash subName slash trialName slash 'trialData_' projectName '_' subName '_' trialName '.mat'];
    end
    save(savePath,'dataStruct','-v6'); % Save the current level's data to the appropriate location.
    
elseif saveModified==1 % Save only the modified data at this level
    % Aggregate the modified data at this level all in one structure (not background pool)
    
    % Save that structure to a temporary file (not background pool)
    
    % Save the contents of that temporary file to the permanent file (background pool)
end