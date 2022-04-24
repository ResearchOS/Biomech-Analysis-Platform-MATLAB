function setArg(subName,trialName,repNum,varargin)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)
% repNum: The repetition number for the current trial (double)
% varargin: The value of each output argument. The name passed in to this function must exactly match what is in the input arguments function (any data type)

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

st=dbstack;
fcnName=st(2).name; % The name of the calling function.

%% Get the level for the current arguments to store. Also get the file path for the current MAT file.
fig=evalin('base','gui;');
if ~isempty(repNum) && ~isempty(trialName)
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
elseif ~isempty(subName)
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];
else
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash projectName '.mat'];
end

%% Get the names of the setArg input arguments. Checks if they are valid names.
argNames=cell(length(varargin),1);
nArgs=length(varargin);
for i=4:nArgs+3
    argNames{i-3}=inputname(i); % NOTE THE LIMITATION THAT THERE CAN BE NO INDEXING USED IN THE INPUT VARIABLE NAMES
    if isempty(argNames{i-3})
        error(['Argument #' num2str(i) ' (output variable #' num2str(i-3) ') is not a scalar name in ' fcnName ' line #' num2str(st(2).line)]);
    end
end

%% NOTE: WHEN FIRST CREATING THE VARIABLE, NEED TO CHECK THAT IT IS UNIQUE (SEARCH FOR MATCHES IN COLUMN 6, CREATED BY APPENDING COLUMN 5 + 2)
% SO BY THE TIME WE RUN SETARG, THERE SHOULD BE NO DANGER OF HAVING NON-UNIQUE METADATA.

%% Get the list of variables already in the MAT file.
if exist(matFilePath,'file')==2
    %% Relate the argNames to the arg function names
%     NOT USED: % Column 3: group name,
    % Column 1: project name,
    % Column 2: analysis name,    
    % Column 3: function name, (includes method number & letter)
    % Column 4: variable name in code,
    % Column 5: variable name in GUI (changes after renaming the variable in the GUI)
    % Column 6: variable save name (never changes! Matches Column 2 + Column 5 when first created. If the variable has been renamed, name does not change.)
    % Column 7: date created
    % Column 8: date modified

    VariableMetadata=load(matFilePath,'VariablesMetadata'); % Get the metadata for all variables in the MAT file.

    %% Filter the existing argNames by the current project, analysis, function, and argument names.
    %     groupIdx=ismember(VariableMetadata(:,3),getappdata(fig,'groupName'));
    projectIdx=ismember(VariableMetadata(:,1),getappdata(fig,'projectName'));
    analysisIdx=ismember(VariableMetadata(:,2),getappdata(fig,'analysisName'));
    fcnIdx=ismember(VariableMetadata(:,4),getappdata(fig,'fcnName'));
    varsIdx=ismember(VariableMetadata(:,5),argNames);

    existIdx=projectIdx & analysisIdx & fcnIdx & varsIdx; % The row idx for metadata of the current variables to save that already exist.
    existVariableMetadata=VariableMetadata(existIdx,:); % Isolate pre-existing variables to save that already exist.

    saveNamesExist=existVariableMetadata(:,6)'; % Extract the names that the data should be saved as.

    VariableMetadata{existIdx,8}=datetime('now'); % Change when the variable was last modified.    

    noExistVarNames=argNames(~ismember(argNames,existVariableMetadata(:,5))); % The names of the variables that do not already exist.

    count=0;
    VariableMetadata{length(existIdx)+1:length(existIdx)+length(noExistVarNames),1:8}=[]; % Initialize additional rows as empty cells.
    saveNamesNoExist=cell(1,length(noExistVarNames));
    for rowNum=length(existIdx)+1:length(existIdx)+length(noExistVarNames)

        count=count+1;
        VariableMetadata{rowNum,1}=getappdata(fig,'projectName');        
        VariableMetadata{rowNum,2}=getappdata(fig,'analysisName');        
        VariableMetadata{rowNum,3}=getappdata(fig,'fcnName');
        VariableMetadata{rowNum,4}=noExistVarNames{count};
        VariableMetadata{rowNum,5}=[]; % Comes from the master list of variable names held <somewhere>.
        VariableMetadata{rowNum,6}=[VariableMetadata{rowNum,5} '_' VariableMetadata{rowNum,2}];
        VariableMetadata{rowNum,7}=datetime('now');
        VariableMetadata{rowNum,8}=datetime('now');

        saveNamesNoExist{1,count}=VariableMetadata{rowNum,6};

    end

    saveNames=[saveNamesNoExist saveNamesExist {'VariableMetadata'}]; % Add the 'VariableMetadata' variable to the var names to save.

    save(matFilePath,saveNames{:},'-v6','-append'); % Append the data to the MAT file. Overwrites existing variables, adds new ones.

else % All variables are new.
    % Initialize the variable metadata with column headers.
    VariableMetadata{1,1}='Project Name';
    VariableMetadata{1,2}='Analysis Name';
    VariableMetadata{1,3}='Function Name';
    VariableMetadata{1,4}='Variable Name In Code';
    VariableMetadata{1,5}='Variable Name In GUI'; % Comes from the master list of variable names held <somewhere>.
    VariableMetadata{1,6}='Variable Save Name (Never Changes)';
    VariableMetadata{1,7}='Date Created';
    VariableMetadata{1,8}='Date Modified';

    saveNames=cell(1,length(argNames)); % Initialize the save names cell array (comma-separated list)

    % Put the variable metadata into the cell array.
    for i=2:length(argNames)+1
        VariableMetadata{i,1}=getappdata(fig,'projectName');
        VariableMetadata{i,2}=getappdata(fig,'analysisName');        
        VariableMetadata{i,3}=getappdata(fig,'fcnName');
        VariableMetadata{i,4}=argNames{i};
        VariableMetadata{i,5}=[]; % Comes from the master list of variable names held <somewhere>.
        VariableMetadata{i,6}=[VariableMetadata{i,5} '_' VariableMetadata{i,2}];
        VariableMetadata{i,7}=datetime('now');
        VariableMetadata{i,8}=datetime('now');

        saveNames{1,i}=VariableMetadata{i,6};
    end

    saveNames=[saveNames {'VariableMetadata'}]; % Add the 'VariableMetadata' variable to the var names to save.

    save(matFilePath,saveNames{:,6},'-v6'); % Save the data for the first time, because the MAT file does not exist yet.

end