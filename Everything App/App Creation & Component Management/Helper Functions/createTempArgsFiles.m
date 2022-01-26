function []=createTempArgsFiles(argsFileName)

%% PURPOSE: CREATE THE TEMPORARY ARGUMENTS FILES FOR THE FUNCTIONS BEING RUN. SHOULD BE CALLED AT THE BEGINNING OF PROCESSING.
% Inputs:
% argsFileName: The name of the file to split up.

% SYNTAX IN ARGS FILE FOR SECTION BREAK LOOKS LIKE THIS:
%% Input: argName
%% Output: argName

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

[folder,name]=fileparts(argsFileName); % Get the folder name that the argument file is in.

savePath=[folder 'Temp Args Files'];

mkdir(savePath); % Create the temporary arguments folder

text=regexp(fileread(argsFileName),'\n','split'); % Read the arguments file.

sectionCount=0; % The number of sections that have been found.
for i=1:length(text)
    
    currLine=text{i}(~isspace(text{i})); % Removes all spaces in the line of text.
    
    if isempty(currLine) || isequal(currLine,char(13)) % If empty or just a newline character
        continue;
    end
    
    if isequal(currLine(1:2),'%%') || i==length(text) % If this is a section break or the end of the file
        if i<length(text)
            sectionStartLine(sectionCount)=i;
        end
        sectionCount=sectionCount+1;
        if sectionCount>1 % Not the first section
            if i<length(text) % Not the last line.
                sectionEndLine(sectionCount)=i-1; % The line before the next section break
            elseif i==length(text) % The last line
                sectionEndLine(sectionCount)=i;
            end
        end                
    end
    
end

%% Create the temporary args files. Split them up into inputs & outputs subfolders.
for i=1:length(sectionCount)
    
    sectionText=text(sectionStartLine(i):sectionEndLine(i));
    firstLine=sectionText{1}(~isspace(sectionText{1}));
    
    if any(ismember(firstLine,'()'))
        error('No parentheses allowed in section break lines, only the argument names');
    end
    
    % Determine whether this is an input or output section
    if length(firstLine)>=9 && isequal(firstLine(1:8),'%%Input:')
        argType=1; % 1 to indicate that it is an input argument, 0 indicates an output argument.
        argName=firstLine(9:end);
        if ~isvarname(argName)
            error(['Input argument ' argName ' is not a valid variable name']);
        end
    elseif length(firstLine)>=9 && isequal(firstLine(1:9),'%%Output:')
        argType=0; % 0 to indicate that it is an output argument, 1 indicates an input argument.
        argName=firstLine(10:end);
        if ~isvarname(argName)
            error(['Output argument ' argName ' is not a valid variable name']);
        end
    else
        error(['Missing ''Input:'' or ''Output:'' identifier in the first line of section ' i]);
    end
    
    clear argsFileText;
    
    switch argType
        case 1 % Input argument
            % Read through the current section text to ensure that there is only one assignment of the projectStruct to the section variable name.
            numIn=0;
            for j=1:length(sectionText)                                
                
                currLine=sectionText{j}(~isspace(sectionText{j}));
                equalsIdx=strfind(currLine,'=');
                semicolonIdx=strfind(currLine,';');
                if ~isempty(equalsIdx) && ~isempty(semicolonIdx)
%                     rightOfEquals=currLine(equalsIdx+1:semicolonIdx-1);
                    leftOfEquals=currLine(1:equalsIdx-1);
                    if isequal(leftOfEquals(1:length(argName)),argName) && isequal(currLine(equalsIdx+length('projectStruct')),'projectStruct')
                        numIn=numIn+1; % This is the assignment of the input argument
                    end
                else
                    continue;
                end
                
            end
            if numIn==0
                error(['Input argument ' argName ' was not specified properly in the arguments function. Check that the section header name and the input arguments names match exactly!']);
            end
            if exist([savePath slash 'Input Args'],'dir')~=7
                mkdir([savePath slash 'Input Args']); % Make the input arguments folder
            end
            fullTempArgPath=[savePath slash 'Input Args' slash name '_' argName '.m']; % Get the name of the temporary arguments file
            fid=fopen(fullTempArgPath,'w'); % Open the temporary arguments file
            argsFileText{1}=['function [' firstLine(9:end) '] = ' name '_' argName '(projectStruct,subName,trialName)']; % Initialize the first line of text of the temporary arguments file         
            argsFileText(3:length(sectionText)+2)=sectionText; % Copy the section text to this variable.
            fwrite(fid,argsFileText); % Write the section text to the temporary arguments file
            fclose(fid); % Close the temporary arguments file.
        case 0 % Output argument
            % Read through the current section text to ensure that there is only one assignment of the section variable name to the projectStruct
            numOut=0;
            for j=1:length(sectionText)                               
                
                if numOut>1
                    error('There should not be more than one projectStruct assignment from the argument!');
                end
                
                currLine=sectionText{j}(~isspace(sectionText{j}));
                equalsIdx=strfind(currLine,'=');
                semicolonIdx=strfind(currLine,';');
                if ~isempty(equalsIdx) && ~isempty(semicolonIdx)
                    rightOfEquals=currLine(equalsIdx+1:semicolonIdx-1);
                    if isequal(rightOfEquals(1:length(argName)),argName) && isequal(currLine(equalsIdx+length('projectStruct')),'projectStruct')
                        numOut=numOut+1; % This is the assignment of the input argument
                        structPath=currLine(1:equalsIdx-1); % Location in the projectStruct to store the data
                        sectionText{j}=['argOut=' currLine(equalsIdx+1:end)]; % Replace the projectStruct path with 'argOut'
                    end
                else
                    continue;
                end
                
            end
            if numOut==0
                error(['Output argument ' argName ' was not specified properly in the arguments function. Check that the section header name and the input arguments names match exactly!']);
            end
            if exist([savePath slash 'Output Args'],'dir')~=7
                mkdir([savePath slash 'Output Args']);
            end            
            fullTempArgPath=[savePath slash 'Output Args' slash name '_' argName '.m']; % Get the name of the temporary arguments file            
            fid=fopen(fullTempArgPath,'w'); % Open the temporary arguments file
            argsFileText{1}=['function [argOut,structPath] = ' name '_' argName '(projectStruct,subName,trialName)']; % Initialize the first line of text of the temporary arguments file         
            argsFileText{2}=['% struct path: ' structPath]; % The location in the projectStruct to save the data.
            argsFileText(3:length(sectionText)+2)=sectionText; % Copy the section text to this variable.
            argsFileText{length(sectionText)+3}=['structPath=' eval(structPath)]; % Put the struct path at the end of the file. This is an output variable.
            fwrite(fid,argsFileText); % Write the section text to the temporary arguments file
            fclose(fid); % Close the temporary arguments file.
    end
    
end