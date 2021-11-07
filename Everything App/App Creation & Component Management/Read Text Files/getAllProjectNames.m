function [allProjectsList]=getAllProjectNames(text)

%% PURPOSE: RETURN ALL PROJECT NAMES FOUND IN THE 'ALLPROJECTS_PROJECTNAMESPATHS.TXT' FILE

count=0;
projNamePrefix='Project Name:';
for i=1:length(text)
    
    if length(text{i})>length(projNamePrefix) && isequal(text{i}(1:length(projNamePrefix)),projNamePrefix)
        count=count+1;
        allProjectsList{count}=text{i}(length(projNamePrefix)+2:length(text{i})); % Isolate each project name.
    end
    
end

if ~exist('allProjectsList','var')
    allProjectsList=''; % Return empty char if no projects.
end