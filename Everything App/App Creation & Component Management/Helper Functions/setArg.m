function setArg(subName,trialName,varargin)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)
% varargin: The value of each output argument. The name passed in to this function must exactly match what is in the input arguments function (any data type)

saveModifiedOnly=0; % Flag to save only the data that has been modified. This value will be obtained from the check box in the Settings tab.

st=dbstack;
fcnName=st(2).name; % The name of the calling function.

argNames=cell(length(varargin),1);
nArgs=length(varargin);
for i=1:nArgs
    argNames{i}=inputname(i); % NOTE THE LIMITATION THAT THERE CAN BE NO INDEXING USED IN THE INPUT VARIABLE NAMES
    if isempty(argNames{i})
        error(['Argument ' num2str(i+2) ' (output variable ' num2str(i) ') is not a scalar name']);
    end
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% 1. Get the name of the corresponding input argument file
fig=evalin('base','gui;'); % Get the gui from the base workspace.
methodLetter=evalin('base','methodLetter;'); % Get the method letter from the base workspace
codePath=getappdata(fig,'codePath'); % The folder path for the code
dataPath=getappdata(fig,'dataPath'); % The folder path for the data
projectName=getappdata(fig,'projectName'); % The project name
argsFolder=[codePath 'Process_' projectName slash 'Arguments']; % The folder path of the arguments file
argsFile=[argsFolder slash fcnName methodLetter '.m']; % The full path to the arguments file
methodNum=strsplit(fcnName,'_Process');
methodNum=methodNum{2}; % The method number
tempDataPath=[dataPath 'MAT Data Files' slash 'Temp Saved' slash]; % Location to save the temporary files when saving only the data that has been modified.
if saveModified==1 && exist(tempDataPath,'dir')~=7
    mkdir(tempDataPath); % Create the temporary data path directory if it does not exist yet
end

if saveModified==1
    tempSaveNames=cell(nArgs,1);    
end

% 2. Read the input argument file to find the address of the corresponding input variable
text=regexp(fileread(argsFile),'\n','split'); % Read in the text of the input arguments function
level=cell(nArgs,1);
allStructPaths=cell(nArgs,1);
for argNum=1:nArgs
    argName=argNames{argNum};
    argFound=0; % Initialize that the current argument was not found
    
    for i=1:length(text)
        currLine=strtrim(text{i}(~isspace(text{i}))); % The current line, with all spaces removed.
        
        if isequal(currLine(1),'%')
            continue; % A comment line
        end
        
        equalsIdx=strfind(currLine,'=');
        if isempty(equalsIdx)
            continue;
        end
        semicolonIdx=strfind(currLine,';');
        if isempty(semicolonIdx)
            continue;
        end
        
        assert(length(semicolonIdx)==1);
        assert(length(equalsIdx)==1);
        
        % At this point, there is a equals sign & semicolon in this line
        if ~isequal(currLine(equalsIdx+1:semicolonIdx-1),argName)
            continue; % Check if this line's variable name to the right of the equals sign matches the argument name.
        end
        
        argFound=1; % The argument was found
        
        structPath=currLine(1:equalsIdx-1); % The structure path.
        splitPath=strsplit(structPath,'.'); % Split the struct path by dots
        assert(isequal(splitPath{1},'projectStruct')); % Check that the projectStruct is the first part of the path
        newPath=splitPath{1};
        level{argNum}='P';
        for j=2:length(splitPath)
            
            if j==2 && isequal(splitPath{j}([1 length(splitPath{j})]),'()')
                newPath=[newPath '.' subName];
                level{argNum}='S';
            elseif j==3 && isequal(splitPath{j}([1 length(splitPath{j})]),'()')
                newPath=[newPath '.' trialName];
                level{argNum}='T';
            elseif isequal(splitPath{j}(1:6),'Method') && (6+sum(isstrprop(splitPath{j},'digit'))+sum(isstrprop(splitPath{j},'alpha')))==length(splitPath{j})
                warning(['Due to automatic method ID assignment, method ID field in output structure paths excluded in ' argName ' in ' argsFile]);
                break; % Don't include the method ID
            else
                if isequal(splitPath{j}([1 length(splitPath{j})]),'()') % There is a dynamic field name where there should not be
                    error(['Too many dynamic field names in argument ' argName ' in ' argsFile]);
                else
                    newPath=[newPath '.' splitPath{j}];
                end
            end
            
        end
        
        break; % Don't look through any more lines
        
    end
    
    % 4. Evaluate the path to store the value of the output argument
    if argFound==0
        beep;
        error(['The argument ' argName ' was not found in the args function ' fcnName methodLetter]);
    end
    
    newPath=[newPath '.Method' methodNum methodLetter]; % Add the method ID to the path name
    assignin('base','structPath',newPath); % The whole structure path for the output variable
    % Store the data to the projectStruct
    assignin('base','argOut',varargin{argNum});
    evalin('base',[newPath '=argOut;']);
    
    allStructPaths{argNum}=newPath;
    
    if saveModifiedOnly==1
        disp(['Saving ' argName ' to temporary file in data path']);
        tempSaveNames{argNum}=[tempDataPath newPath '.mat']; % The full path name of the temporary save file for this argument
        save(tempSaveNames{argNum},varargin{argNum},'-v6'); % Save just that data to the file.        
    end
    
end

%% Save the data to file
% Get the data at the appropriate level
savePathRoot=[dataPath 'MAT Data Files'];
if ~isvarname(subName)
    subName=['S' subName];
end
if ~isvarname(trialName)
    trialName=['T' trialName];
end
if saveModifiedOnly==0 % Save all data
    if any(ismember(level,{'P'}))
        savePath.P=[savePathRoot slash projectName '.mat'];
        subNames=getappdata(fig,'subjectNames');
        fldNames=evalin('base','fieldnames(projectStruct);');
        fldNames=fldNames(~ismember(fldNames,subNames)); % Exclude subject names from field names
        for i=1:length(fldNames)
            projData.(fldNames{i})=evalin('base',['projectStruct.(' fldNames{i} ')']);
        end
    end
    if any(ismember(level,{'S'}))
        savePath.S=[savePathRoot slash subName slash subName '_' projectName '.mat'];
        trialNameColNum=getappdata(fig,'trialNameColumnNum');
        subjNameColNum=getappdata(fig,'subjectCodenameColumnNum');
        logVar=evalin('base','logVar');
        rowNums=ismember(logVar(:,subjNameColNum),subName); % The row numbers for the current subject
        trialNames=logVars(rowNums,trialNameColNum); % The trial names for the current subject
        fldNames=evalin('base',['fieldnames(projectStruct.' subName ');']);
        fldNames=fldNames(~ismember(fldNames,trialNames)); % Exclude trial names from field names
        for i=1:length(fldNames)
            subjData.(subName).(fldNames{i})=evalin('base',['projectStruct.' subName '.(' fldNames{i} ')']);
        end
    end
    if any(ismember(level,{'T'}))
        savePath.T=[savePathRoot slash subName slash trialName '_' subName '_' projectName '.mat'];
        trialData.(subName).(trialName)=evalin('base',['projectStruct.' subName '.' trialName]);
    end
    
    % Save the data to file
    if any(ismember(level,'P'))
        save(savePath.P,projData,'-v6'); 
    end
    if any(ismember(level,'S'))
       save(savePath.S,subjData,'-v6');  
    end
    if any(ismember(level,'T'))
       save(savePath.T,trialData,'-v6'); 
    end        
elseif saveModifiedOnly==1 % Save only the data that has been modified, save the modified data to a temporary file, and use a background pool to then save the temporary files to the long-term storage files.
    p=backgroundPool; % Get the background pool
    f=parfeval(p,@longTermSave,0,tempSaveNames,dataPath,level,projectName);
%     afterEach(f,disp([argName ' moved to long term save file']),0);
    
end