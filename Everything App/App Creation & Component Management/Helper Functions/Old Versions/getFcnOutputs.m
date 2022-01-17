function [fcnOutputs]=getFcnOutputs(filePath,methodLetter)

%% PURPOSE: READ THROUGH THE TEXT OF A PROCESSING FUNCTION AND IDENTIFY THE OUTPUT VARIABLES AT PROJECT, SUBJECT, & TRIAL LEVEL
% Inputs:
% filePath: The full path to the processing function file (char)
% methodLetter: The method letter for the current processing function input arguments (char)

% Outputs:
% fcnOutputs: Contains all path names to the output variables in the struct, in generic form (struct of cell arrays of chars)

text=regexp(fileread(filePath),'\n','split'); % Read in the .m file, where each line is one element of a cell array
outCount.P=0;
outCount.S=0;
outCount.T=0;

for lineNum=1:length(text)
    
    currLine=strtrim(text{lineNum}); % Text of the current line
    
    if isequal(currLine(1),'%')
        continue; % Skip comment lines
    end
    
    if ~any(contains(currLine,'.'))
        continue; % If there is no dot indexing in this line, skip it.
    end
    
    %     currLine=strtrim(currLine); % Remove leading & trailing white spaces
    
    if isequal(currLine(1:8),'projData')
        level='P';
    elseif isequal(currLine(1:8),'subjData')
        level='S';
    elseif isequal(currLine(1:9),'trialData')
        level='T';
    else
        continue; % Skip this line if not an output variable assignment.
    end
    
    currLine=currLine(~isspace(currLine)); % Remove significant white spaces
    
    equalsIdx=strfind(currLine,'='); % Find index of equals sign
    
    if isempty(equalsIdx)
        continue; % Don't use this line if there's no equals sign.
    end
    
    currStructPath=strsplit(currLine(1:equalsIdx-1),'.'); % Split the struct path up by the dots
    
    %     if isequal(level,'P')
    %         newStructPath='projectStruct';
    %     elseif isequal(level,'S')
    %         newStructPath='projectStruct.(subName)';
    %     elseif isequal(level,'T')
    %         newStructPath='projectStruct.(subName).(trialName)';
    %     end
    newStructPath='dataStruct'; % To match the storeAndSaveVars.m
    for i=2:length(currStructPath)
        
        newStructPath=[newStructPath '.' currStructPath{i}]; % Generic format (i.e. projectStruct.(subName).(trialName)...)
        
        %         if isequal(currStructPath{i}([1 end]),'()')
        %             if i==2
        %                 level='S';
        %             elseif i==3
        %                 level='T';
        %             end
        %         end
        
        if contains(currStructPath{i},'Method') && contains(currStructPath{i},'methodLetter')
            numIdx=isstrprop(currStructPath{i},'digit'); % Get the idx of the method number
            newStructPath=[newStructPath '.Method' currStructPath{i}(numIdx) methodLetter]; % Construct the method number & letter field
            break; % Stop at the method number & letter field name.
        end
        
    end
    
    % Store the function names
    outCount.(level)=outCount.(level)+1;
    fcnOutputs.(level){outCounts.(level)}=newStructPath;
    
end