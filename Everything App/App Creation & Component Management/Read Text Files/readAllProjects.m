function [text,fullFileName]=readAllProjects(everythingPath)

%% PURPOSE: RETURN THE TEXT OF THE PROJECT LEVEL PATH NAMES, IF THE FILE EXISTS. OTHERWISE RETURN EMPTY CHAR

slash=filesep;
fullFileName=[everythingPath 'App Creation & Component Management' slash 'allProjects_ProjectNamesPaths.txt'];
if exist(fullFileName,'file')==2 % If the file exists.
    text=regexp(fileread(fullFileName),'\n','split'); % Read in the file, where each line is one cell.
    if length(text)==1 && isequal(text{1},'') % File exists but is empty, return empty char.
        text='';
    end
    if length(text)==3 && isequal(text{1},'Project Name: Enter Project Name') && isequal(text{3},'Most Recent Project Name: Enter Project Name') && isempty(text{2})
        text='';
    end
else % If the file does not exist.
    text='';
end

if iscell(text) % Check for extraneous newline characters.
    for i=1:length(text)
        if isempty(text{i})
            text{i}='';
            continue;
        end
        if isequal(text{i}(end),char(13)) % If there's a newline char at the end of the project name
            % This seems to really only happen when I switch between GitHub branches.
            text{i}=text{i}(1:end-1);
        end
    end
    % If the file had to be modified to get rid of the newline characters, save it back to "normal".
    fid=fopen(fullFileName,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);        
end