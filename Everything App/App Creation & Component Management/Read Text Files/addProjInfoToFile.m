function [text]=addProjInfoToFile(text,projectName,prefix,data,appendBool)

%% PURPOSE: HELPER FUNCTION TO EASILY PUT NEW METADATA INTO THE TEXT FILE 'allProjects_ProjectNamesPaths.txt'
% Inputs:
% text: The contents of the 'allProjects_ProjectNamesPaths.txt' file, where each line is one element (cell array)
% projectName: The project to be modifying data for. (char)
% prefix: The specific metadata field to modify. (char)
% data: The metadata to add/replace in the file. (char)
% appendBool: 1 to append to existing data, 0 to replace the line entirely (double)

% Outputs:
% newText: The new text file, either with the data modified (if previously existing) or added (if new metadata field for the project)

if ~exist('appendBool','var')
    appendBool=0;
end

% Check if the current project name is in the text file
allProjectsList=getAllProjectNames(text);
if isempty(allProjectsList)
    warning('No projects in the allProjects txt file');
    return; % No projects in the file.
end
if ~ismember(projectName,allProjectsList) % Check if the project exists in this text file.
    warning(['Project: ' projectName ' Not Found in the allProjects txt File']);
    return;
end

% Check if the current prefix is found in the text file.
projectFound=0;
projNamePrefix='Project Name:';
projectNameLine=0;
for i=1:length(text)
    if isempty(text{i})
        if projectFound==0
            continue; % Continue to the next line.
        elseif projectFound==1
            break; % Finished with this project.
        end
    end
    
    if projectFound==0 && length(text{i})>=length(projNamePrefix)+1+length(projectName) && isequal(text{i}(length(projNamePrefix)+2:length(projNamePrefix)+1+length(projectName)),projectName)
        projectFound=1;
        projectNameLine=i;
        continue;
    end
    
    if projectFound==0
        continue;                
    end
    
    % Now have found the project, checking if the prefix was found.
    if length(text{i})>=length(prefix) && isequal(text{i}(1:length(prefix)),prefix)
        if appendBool==0
            text{i}=[prefix ' ' data]; % Replaces the data
        elseif appendBool==1
            text{i}=[text{i} data];
        end
        return; % After modifying an existing data, stop this function.
    end
    
    
end

% The metadata field did not already exist in this project.
preText=text(1:projectNameLine);
insertText={[prefix ' ' data]};
postText=text(projectNameLine+1:length(text));

text=horzcat(preText,insertText,postText);