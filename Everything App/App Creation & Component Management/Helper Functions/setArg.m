function setArg(subName,trialName,repNum,varargin)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% STORES THE VARIABLE FIRST INTO THE PROJECTSTRUCT, THEN SAVES IT TO THE CORRESPONDING MAT FILE.
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
if ~isempty(repNum) && ~isempty(trialName) % Trial level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash trialName '_' subName '_' projectName '.mat'];
elseif ~isempty(subName) % Subject level
    matFilePath=[getappdata(fig,'dataPath') 'MAT Data Files' slash subName slash subName '_' projectName '.mat'];
else % Project level
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

saveNames=cell(1,length(argNames)); % Initialize the save names cell array (comma-separated list)

if exist(matFilePath,'file')==2
    %% Relate the argNames to the arg function names
    % VariablesMetadata fieldnames:
    % ProjectName: The active project when generating this variable (char)
    % AnalysisName: The active analysis when generating this variable (char)
    % FunctionName: The function used to generate this variable (full method ID, number and letter) (char)
    % NameInGUI: The variable name as represented in the GUI (may change if the user decides to rename the variable, otherwise static) (char)
    % NameInMAT: The variable name used to store the data in the MAT file (static, will never change, even if NameInGUI changes) (char)
    % NameInCode: The variable name in the code, which may change from function to function. (char)
    % DateCreated: When the variable identified by NameInMAT was first created (char)
    % DateModified: When the variable identified by NameInMAT was last modified (char)

    VariablesMetadata=load(matFilePath,'VariablesMetadata'); % Get the metadata for all variables in the MAT file.

    %% Filter the existing argNames by the current project, analysis, function, and argument names.
    projectIdx=ismember(VariablesMetadata.ProjectName,getappdata(fig,'projectName'));
    analysisIdx=ismember(VariablesMetadata.AnalysisName,getappdata(fig,'analysisName'));
    fcnIdx=ismember(VariablesMetadata.OutputFunctionName,getappdata(fig,'fcnName'));
    varsIdx=ismember(VariablesMetadata.NameInCode,argNames);

    existIdx=projectIdx & analysisIdx & fcnIdx & varsIdx; % The idx for the variables being saved that already exist.
    existVarNamesInCode=VariablesMetadata.NameInCode(existIdx,:); % Isolate names in code of pre-existing variables to save.

    currTime=char(datetime('now')); % Change when the variable was last modified.        

    %% Modify the pre-existing vars' data and metadata.
    existRows=find(existIdx==1);
    count=0;
    for rowNum=existRows

        VariablesMetadata.DateModified{rowNum,1}=currTime;

        count=count+1;
        saveNames{1,count}=VariablesMetadata.NameInMAT{rowNum,1};

%         eval([saveNames{1,count} '=' ])

    end

    %% Add new vars' data and metadata.  
    noExistVarNamesInCode=argNames(~ismember(argNames,existVarNamesInCode)); % The names of the variables to save that do not already exist.

    for rowNum=length(existIdx)+1:length(existIdx)+length(noExistVarNamesInCode)

        count=count+1;
        VariablesMetadata.ProjectName{rowNum,1}=getappdata(fig,'projectName');        
        VariablesMetadata.AnalysisName{rowNum,1}=getappdata(fig,'analysisName');        
        VariablesMetadata.OutputFunctionName{rowNum,1}=getappdata(fig,'fcnName');
        VariablesMetadata.NameInCode{rowNum,1}=noExistVarNamesInCode{count};
        VariablesMetadata.NameInGUI{rowNum,1}=''; % Unique! Comes from the master list of variable names held <somewhere>. Shown in GUI universally, across all analyses and functions.
        VariablesMetadata.NameInMAT{rowNum,1}=[VariablesMetadata.NameInGUI{rowNum,1} '_' VariablesMetadata.AnalysisName{rowNum,1}]; % By definition must be unique!        
        VariablesMetadata.DateCreated{rowNum,1}=char(datetime('now'));
        VariablesMetadata.DateModified{rowNum,1}=char(datetime('now'));

        saveNames{1,count}=VariablesMetadata.NameInMAT{rowNum,1};

    end

    % Do I need to order the fields or are they still ordered after creating the VariableMetadata variable the first time?

    saveNames=[saveNames {'VariableMetadata'}]; % Add the 'VariableMetadata' variable to the var names to save.

    save(matFilePath,saveNames{:},'-v6','-append'); % Append the data to the MAT file. Overwrites existing variables, adds new ones.

else % All variables are new.      
    % Put the variable metadata into the cell array.
    for count=1:length(argNames)
        VariablesMetadata.ProjectName{count,1}=getappdata(fig,'projectName');
        VariablesMetadata.AnalysisName{count,1}=getappdata(fig,'analysisName');
        VariablesMetadata.OutputFunctionName{count,1}=getappdata(fig,'fcnName');
        VariablesMetadata.NameInCode{count,1}=argNames{count}; % Not unique.
        VariablesMetadata.NameInGUI{count,1}=''; % Unique! Comes from the master list of variable names held <somewhere>. Shown in GUI universally, across all analyses and functions.
        VariablesMetadata.NameInMAT{count,1}=[VariablesMetadata.NameInGUI{count,1} '_' VariablesMetadata.AnalysisName{count,1}]; % By definition must be unique!
        VariablesMetadata.DateCreated{count,1}=char(datetime('now'));
        VariablesMetadata.DateModified{count,1}=char(datetime('now'));

        saveNames{1,count}=VariablesMetadata.NameInMAT{count,1};
    end

    VariablesMetadata=orderfields(VariablesMetadata); % Alphabetizes field names.

    saveNames=[saveNames {'VariableMetadata'}]; % Add the 'VariableMetadata' variable to the var names to save.

    save(matFilePath,saveNames{:},'-v6'); % Save the data for the first time, because the MAT file does not exist yet.

end