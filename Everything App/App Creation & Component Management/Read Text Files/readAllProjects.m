function [text,fullFileName]=readAllProjects()

%% PURPOSE: READ THE PROJECT LEVEL PATH NAMES, IF THE FILE EXISTS. OTHERWISE RETURN EMPTY CHAR

fileName='allProjects_ProjectNamesPaths.txt';
if ispc==1 % Get the Documents path for PC
    userProfile=getenv('USERPROFILE'); % Get the name of the user logged in to the computer
    documentsFolderPath=[userProfile '\Documents\'];
    if ~isfolder([documentsFolderPath 'PGUI\'])
        mkdir([documentsFolderPath 'PGUI\']);
    end
    documentsFolderPath=[documentsFolderPath 'PGUI\'];
elseif ismac==1 % Get the Documents path for Mac
    userProfile=getenv('USER'); % Get the name of the user logged in to the computer
    documentsFolderPath=['Macintosh HD/Users/' userProfile '/'];
    if ~isfolder([documentsFolderPath 'PGUI/'])
        mkdir([documentsFolderPath 'PGUI/']);
    end
    documentsFolderPath=[documentsFolderPath 'PGUI/'];
end

fullFileName=[documentsFolderPath fileName];
if exist(fullFileName,'file')==2 % If the file exists.
    text=regexp(fileread(fullFileName),'\n','split'); % Read in the file, where each line is one cell.  
    if length(text)==1 && isequal(text{1},'') % File exists but is empty, return empty char.
        text='';
    end
else % If the file does not exist.
    text='';
end