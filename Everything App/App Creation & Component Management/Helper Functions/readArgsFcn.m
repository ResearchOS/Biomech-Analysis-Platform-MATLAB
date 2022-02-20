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
args=strsplit(firstLineSplit{2},','); % Isolates subName, trialName, & repNum args as one block
args{end}=args{end}(1:end-1); % Remove parentheses from last arg

% Parse the file path for the method ID
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end
pathSplit=strsplit(filePath,slash);
fileName=pathSplit{end};
if ~isempty(strfind(fileName,'_Import'))
    fileSuffix=strsplit(fileName,'_Import');
elseif ~isempty(strfind(fileName,'_Process'))
    fileSuffix=strsplit(fileName,'_Process');
elseif ~isempty(strfind(fileName,'_Plot'))
    fileSuffix=strsplit(fileName,'_Plot');
end
methodID=fileSuffix{2}(1:strfind(fileSuffix{2},'.')-1);

argCount=0;
fcnCount=0;
for i=1:length(text)
    
    currLine=text{i}(~isspace(text{i})); % Remove all white space.

    if length(currLine)>length('function') && isequal(currLine(1:length('function')),'function')
        fcnCount=fcnCount+1;
        continue; % This line won't be an argument line
    end

    if fcnCount<2
        continue; % Only start parsing the file after reaching the input args functions.
    end
    
    if ~contains(currLine,'=')
        continue; % Check for equals sign
    end

    percIdx=strfind(currLine,'%');
    equalsIdx=strfind(currLine,'=');

    if ~isempty(percIdx) && (percIdx==1 || percIdx<equalsIdx)
        continue; % This line is a comment
    end
    
    assert(length(equalsIdx)==1); % There can only be one equals sign per line.

    startIdx=strfind(currLine,'projectStruct');
    
    if isempty(startIdx)
        continue; % This variable assignment is not from the projectStruct.
    end
    
    semiColonIdx=strfind(currLine,';');
    assert(length(semiColonIdx)==1,['Multi-line statements not supported in args functions! Missing semicolon in line ' num2str(i) ' in function: ' filePath]); % There can only be one semicolon per line

    % Check the format of output projectStruct paths.
    assert(equalsIdx<startIdx,['Assignments to projectStruct should be implicit. Change projectStruct path to character vector on line ' num2str(i) ' in function ' filePath]);

    isOutput=0; % If input path, should contain method ID.
    if isequal(currLine(equalsIdx+1),'''') && isequal(currLine(semiColonIdx-1),'''') % Output assignment
        equalsIdx=equalsIdx+1; % Adjust for character vector
        semiColonIdx=semiColonIdx-1;
        isOutput=1; % Specify that this is an output path and should not contain a method ID
    end
    
    initPath=currLine(equalsIdx+1:semiColonIdx-1);
    
    splitPath=strsplit(initPath,'.');
    
    argCount=argCount+1;
    
    % Reconstruct the path name.
    paths{argCount,1}='';
    methodIDFound=0; % Initialize that no method ID field was found for this argument
    for j=1:length(splitPath) 
        if length(splitPath{j})>=8 && ~isempty(strfind(splitPath{j}(1:6),'Method'))
            methodIDFound=1;
            if isOutput==1
                error(['projectStruct assignment paths should not have method ID! Line ' num2str(i) ' in function: ' filePath]);
            end
        end
        if j==1
            paths{argCount,1}=splitPath{1};
        else
            paths{argCount,1}=[paths{argCount} '.' splitPath{j}];
        end        
    end    
    if isOutput==0 && methodIDFound==0
        error(['projectStruct input paths should have method ID field! Line ' num2str(i) ' in function: ' filePath]);
    elseif isOutput==1 && methodIDFound==0 % This is correct. Now insert the method ID field.
        paths{argCount,1}=[paths{argCount} '.Method' methodID];
    end
    
end

if ~exist('paths','var')
    error('Incorrectly formatted args function!');
end

if length(paths)>length(unique(paths))
    error('Multiple arguments specified exactly the same. Beware of overwriting data!');
end