function [argIn]=getArg(argName,subName,trialName)

%% PURPOSE: RETURN ONE INPUT ARGUMENT TO A PROCESSING FUNCTION AT EITHER THE PROJECT, SUBJECT, OR TRIAL LEVEL
% Inputs:
% argName: The name of the input argument. Spelling must match the input arguments function (char)
% subName: The subject name, if accessing subject or trial level data. If project level data, not inputted. (char)
% trialName: The trial name, if accessing trial data. If subject or project level data, not inputted (char)

% Outputs:
% argIn: The argument to pass in to the processing function

if nargin<=2 % Subject level data
    trialName='';
end
if nargin==1 % Project level data
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
projectName=getappdata(fig,'projectName'); % The project name
argsFolder=[codePath 'Process_' projectName slash 'Arguments']; % The folder path of the arguments file
argsName=[argsFolder slash fcnName methodLetter '.m']; % The full path to the arguments file

% 2. Read the input argument file to find the address of the corresponding input variable
text=regexp(fileread(argsName),'\n','split'); % Read in the text of the input arguments function

argFound=0; % Initialize that the input argument was not found
projectStructArg=0; % Initialize that the argument is not in the structure
breakFlag=0; % Indicates whether to stop looking through all lines. Stop looking if found arg is a scalar, otherwise keep looking.
for i=1:length(text)
    currLine=strtrim(text{i}(~isspace(text{i}))); % The current line, with all spaces removed.
    
    if isequal(currLine(1),'%')
        continue; % Ignore comment lines
    end
    
    if ~isequal(currLine(1:length(argName)),argName)
        continue; % This is not the line with the input argument
    end
    
    equalsIdx=strfind(currLine,'=');
    assert(length(equalsIdx)==1,['Should only be 1 equals sign in line: ' num2str(i)]); % There is only one equals sign in this line
    semicolonIdx=strfind(currLine,';');
    assert(length(semicolonIdx)==1,['Should only be 1 semicolon in line: ' num2str(i)]); % There is only one semicolon in this line
    if ~ismember({currLine(length(argName)+1)},{'=','.'}) % The next character must be either an '=' or a '.' (if struct)
        continue; % Make sure that the full argument name was found, not just a subset of one.
    end    
    argFound=1; % Flag that the argument has been found
    newArgName=currLine(1:equalsIdx-1); % If the argument is a structure, captures the entire structure path
    if isequal(newArgName,argName)
        breakFlag=1;
    else % The argument is not a scalar (could be struct, cell, or other array)
        argIdx=currLine(length(argName)+1:equalsIdx-1); % The indexing of the arg.
    end
    
    structPath=currLine(equalsIdx+1:semicolonIdx-1); % The structure path. Need to ensure it ends at the method number
    splitPath=strsplit(structPath,'.'); % Split the struct path by dots
    if isequal(splitPath{1},'projectStruct') % Check if the projectStruct is the first part of the path
        projectStructArg=1; % The argument is within the structure
        newPath=splitPath{1};
        for j=2:length(splitPath)
            % 3. Replace (subName) and (trialName) in the input argument paths with the values passed in to this function
            if j==2 && isequal(splitPath{j}([1 length(splitPath{j})]),'()')
                newPath=[newPath '.' subName];
            elseif j==3 && isequal(splitPath{j}([1 length(splitPath{j})]),'()')
                newPath=[newPath '.' trialName];
            else
                newPath=[newPath '.' splitPath{j}];
            end
            
            % Ensure that the method ID is the entirety of this field name
            if isequal(splitPath{j}(1:6),'Method') && (6+sum(isstrprop(splitPath{j},'digit'))+sum(isstrprop(splitPath{j},'alpha')))==length(splitPath{j})
                if length(splitPath)>j
                    warning(['Omitted field names of data path in structure after method ID field. Arg: ' argName]);
                end
                break; % Stop parsing the path after the method ID, even if more was specified.
            elseif length(splitPath)==j % The end of the path name has been reached, but no method ID was specified.
                error(['No method ID field found for argument ' argName ' in: ' argsName]);
            end
            
        end
%         assignin('base','structPath',newPath); % Put the structure path in to the base workspace
    else % This argument is not in the projectStruct, it is something manually specified.
        argIn=eval(structPath);
    end
    
    % For a scalar input argument
    if breakFlag==1
        if projectStructArg==1
            if evalin('base','existField(projectStruct,structPath)')==1 % Check that the specified argument field actually exists in the structure.
                argIn=eval([newPath ';']); % Evaluate the structure path in the base workspace, and it is returned here.
            else
                error(['The argument ' argName ' was not found in the projectStruct at the path: ' newPath]);
            end
        end
        break; % Don't look through any more lines
    end
    
    % For non-scalar args, do the indexing here.
    % FIGURE OUT THIS LOGIC
    argName=eval([argName argIdx '=' argIn ';']);
    argIn=argName
    
end

% 4. Evaluate the path to return the value of the input argument
if argFound==0
    beep;
    error(['The argument ' argName ' was not found in the args function ' fcnName methodLetter]);
end