function [text,fullFileName]=readAllProjects(everythingPath)

%% PURPOSE: READ THE PROJECT LEVEL PATH NAMES, IF THE FILE EXISTS. OTHERWISE RETURN EMPTY CHAR

slash=everythingPath(end); % Assumed to be a slash at the end of the path
fullFileName=[everythingPath 'App Creation & Component Management' slash 'allProjects_ProjectNamesPaths.txt'];
if exist(fullFileName,'file')==2 % If the file exists.
    text=regexp(fileread(fullFileName),'\n','split'); % Read in the file, where each line is one cell.  
    if length(text)==1 && isequal(text{1},'') % File exists but is empty, return empty char.
        text='';
    end
else % If the file does not exist.
    text='';
end