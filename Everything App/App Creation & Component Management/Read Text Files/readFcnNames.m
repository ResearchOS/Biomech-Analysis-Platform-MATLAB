function [text]=readFcnNames(fcnNamesFilePath)

%% PURPOSE: READ THE PROJECT'S FUNCTION FILE NAMES INTO MATLAB

% Inputs:
% fcnNamesFilePath: The full path name to the current project's function names file path (char)

% Outputs:
% text: The text file

if exist(fcnNamesFilePath,'file')==2 % If the file exists
    text=regexp(fileread(fcnNamesFilePath),'\n','split'); % Read in the file
    if length(text)==1 && isequal(text{1},'') % File exists but is empty, return empty char
        text='';
    end
    if length(text)==3 && isequal(text{1},'Group Name: Create Function Group') && isequal(text{3},'Most Recent Group Name: Create Function Group') && isempty(text{2})
        text='';
    end
else % If the file does not exist
    text='';
end

if iscell(text)
    for i=1:length(text)
        if isempty(text{i})
            text{i}='';
            continue;
        end
        if isequal(text{i}(end),char(13))
            text{i}=text{i}(1:end-1);
        end
    end
    % If the file were modified to get rid of the newline characters, save the file
    fid=fopen(fcnNamesFilePath,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);
end