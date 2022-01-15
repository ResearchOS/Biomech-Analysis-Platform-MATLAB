function setArg(argName,argVal,subName,trialName)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% argName: The name of the output argument. Spelling must match the input arguments function (char)
% argVal: The value of the output argument (any data type)
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)

% Outputs:
% argIn: The argument to pass in to the processing function

if nargin<=3 % Subject level data
    trialName='';
end
if nargin==2 % Project level data
    subName='';
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

% 1. Get the name of the corresponding input argument file
fig=evalin('base','gui;'); % Get the gui from the base workspace.
st=dbstack;
fcnName=st(2).name; % The name of the calling function.
methodLetter=evalin('base','methodLetter;'); % Get the method letter from the base workspace
codePath=getappdata(fig,'codePath'); % The folder path for the code
dataPath=getappdata(fig,'dataPath'); % The folder path for the data
projectName=getappdata(fig,'projectName'); % The project name
argsPath=[codePath 'Process_' projectName slash 'Arguments']; % The folder path of the arguments file
argsName=[argsPath slash fcnName methodLetter '.m']; % The full path to the arguments file
methodNum=strsplit(fcnName,'_Process');
methodNum=methodNum{2}; % The method number

% 2. Read the input argument file to find the address of the corresponding input variable
text=regexp(fileread(argsName),'\n','split'); % Read in the text of the input arguments function

argFound=0; % Initialize that the input argument was not found
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
        continue;
    end
    
    argFound=1; % The argument was found
    
    structPath=currLine(1:equalsIdx-1); % The structure path.
    splitPath=strsplit(structPath,'.'); % Split the struct path by dots
    assert(isequal(splitPath{1},'projectStruct')); % Check that the projectStruct is the first part of the path
    newPath=splitPath{1};
    level='P';
    for j=2:length(splitPath)
        
        if j==2 && isequal(splitPath{j}([1 length(splitPath{j})]),'()')
            newPath=[newPath '.' subName];
            level='S';
        elseif j==3 && isequal(splitPath{j}([1 length(splitPath{j})]),'()')
            newPath=[newPath '.' subName];
            level='T';
        elseif isequal(splitPath{j}(1:6),'Method') && (6+sum(isstrprop(splitPath{j},'digit'))+sum(isstrprop(splitPath{j},'alpha')))==length(splitPath{j})
            warning(['Due to automatic assignment, method ID field in output structure paths excluded in ' argName ' in ' argsName]);
            break; % Don't include the method ID
        else
            if isequal(splitPath{j}([1 length(splitPath{j})]),'()') % There is a dynamic field name where there should not be
                error(['Too many dynamic field names in argument ' argName ' in ' argsName]);
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
else
    newPath=[newPath '.Method' methodNum methodLetter]; % Add the method ID to the path name
    assignin('base','structPath',newPath); % The whole structure path for the output variable
end

% Store the data to the projectStruct
assignin('base','argOut',argVal);
evalin('base',[newPath '=argOut;']);


% Save the data to file
% Get the data at the appropriate level
savePathRoot=[dataPath 'MAT Data Files'];
if ~isvarname(subName)
    subName=['S' subName];
end
if ~isvarname(trialName)
    trialName=['T' trialName];
end
saveModifiedOnly=0; % Flag to save only the data that has been modified. This value will be obtained from the check box in the Settings tab.
if saveModifiedOnly==0 % Save all data
    switch level
        case 'P'
            savePath=savePathRoot;
            subNames=getappdata(fig,'subjectNames');
            fldNames=evalin('base','fieldnames(projectStruct);');
            fldNames=fldNames(~ismember(fldNames,subNames)); % Exclude subject names from field names
            for i=1:length(fldNames)
                data.(fldNames{i})=evalin('base',['projectStruct.(' fldNames{i} ')']);
            end
        case 'S'
            savePath=[savePathRoot slash subName];
            trialNameColNum=getappdata(fig,'trialNameColumnNum');
            subjNameColNum=getappdata(fig,'subjectCodenameColumnNum');
            logVar=evalin('base','logVar');
            rowNums=ismember(logVar(:,subjNameColNum),subName); % The row numbers for the current subject
            trialNames=logVars(rowNums,trialNameColNum); % The trial names for the current subject
            fldNames=evalin('base',['fieldnames(projectStruct.' subName ');']);
            fldNames=fldNames(~ismember(fldNames,trialNames)); % Exclude trial names from field names
            for i=1:length(fldNames)
                data.(fldNames{i})=evalin('base',['projectStruct.' subName '.(' fldNames{i} ')']);
            end
        case 'T'
            savePath=[savePathRoot slash subName slash trialName];
            data=evalin('base',['projectStruct.' subName '.' trialName]);
    end
    
    save(savePath,data,'-v6');
elseif saveModifiedOnly==1 % Save only the data that has been modified, save the modified data to a temporary file, and use a background pool to then save the temporary files to the long-term storage files.
    
    
    
end