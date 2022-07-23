function [text,textPath]=readAllArgsTextFile(everythingPath,projectName,guiTab)

%% PURPOSE: READ THE TEXT FILE CONTAINING ALL ARGUMENT NAMES AND RETURN THOSE NAMES, NOT ASSOCIATED TO ANY FUNCTION.
% Inputs:
% everythingPath: The full path to the whole GUI folder (char)
% projectName: The current project's name (char)
% guiTab: Indicates whether to extract 'Import', 'Process', or 'Plot' args

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

textPath=[everythingPath 'App Creation & Component Management' slash 'allProjects_allArgsNames.txt'];

if exist(textPath,'file')~=2
    text='';    
    return;
end

text=regexp(fileread(textPath),'\n','split');

needToSave=0;
if iscell(text) % Check for extraneous newline characters.
    for i=1:length(text)
        if isempty(text{i})
            text{i}='';
            continue;
        end
        if isequal(text{i}(end),char(13)) % If there's a newline char at the end of the project name
            % This seems to really only happen when I switch between GitHub branches.
            needToSave=1;
            text{i}=text{i}(1:end-1);
        end
    end
    % If the file had to be modified to get rid of the newline characters, save it back to "normal".
    if needToSave==1
        fid=fopen(textPath,'w');
        fprintf(fid,'%s\n',text{1:end-1});
        fprintf(fid,'%s',text{end});
        fclose(fid);
    end
end

if size(text,1)<size(text,2)
    text=text'; % Ensure that it's a column vector
end