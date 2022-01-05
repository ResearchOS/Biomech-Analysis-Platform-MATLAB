function [paths]=readArgsFcn(filePath,subName,trialName)

%% PURPOSE: READ THE TEXT OF THE ARGUMENTS FUNCTION TO ISOLATE THE PATH NAMES OF ALL INPUT VARIABLES
% Inputs:
% filePath: The absolute path name of the arguments file.
% subName: The subject name within the struct (char)
% trialName: The trial name within the struct (char)

% Outputs:
% paths: The path names within the struct for each variable (cell array of chars)

% Load the text file.
text=regexp(fileread(filePath),'\n','split'); % Each line is one element of the cell now.

% Criteria:
% 1. Must have an equals sign in the line.
% 2. Directly after the equals sign must have 'projectStruct'
% 3. Take everything from right after the equals sign until right before the semicolon
% 4. If there are field names wrapped in parentheses, check what's in the parentheses and match it with the corresponding argument in the first line.
% 5. In the end, will return one singular char array for each path.

firstLineSplit=strsplit(text{1}(~isspace(text{1})),'('); % Removes spaces, isolates arguments from function name.
argsBlockSplit=strsplit(firstLineSplit{2},'projectStruct,'); % Isolates subName, trialName, & repNum args as one block
args=strsplit(argsBlockSplit{2},','); % Each arg variable individually. In order: subject name,trial name, repetition number
args{3}=args{3}(1:end-1); % Remove the final parentheses.

argCount=0;
for i=1:length(text)
    
    currLine=text{i}(~isspace(text{i})); % Remove all white space.
    
    if ~contains(currLine,'=')
        continue; % Check for equals sign
    end
    
    equalsIdx=strfind(currLine,'=');
    assert(length(equalsIdx)==1); % There can only be one equals sign per line.
    
    if ~isequal(currLine(equalsIdx+1:equalsIdx+length('projectStruct')),'projectStruct')
        continue; % This variable assignment is not from the projectStruct.
    end
    
    semiColonIdx=strfind(currLine,';');
    assert(length(semiColonIdx)==1); % There can only be one semicolon per line
    
    initPath=currLine(equalsIdx+1:semiColonIdx-1);
    
    splitPath=strsplit(initPath,'.');
    
    if isequal(splitPath{2},['(' args{1} ')'])
        splitPath{2}=subName; % Replace variable with actual subject name
    end
    
    if isequal(splitPath{3},['(' args{2} ')'])
        splitPath{3}=trialName; % Replace variable with actual trial name
    end
    
    argCount=argCount+1;
    
    % Reconstruct the path name.
    paths{argCount,1}='';
    for j=1:length(splitPath)        
        if j==1
            paths{argCount,1}=splitPath{1};
        else
            paths{argCount,1}=[paths{argCount} '.' splitPath{j}];
        end        
    end    
    
end