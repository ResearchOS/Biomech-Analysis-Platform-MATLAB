function [projectNamesPaths]=isolateProjectNamesPaths(text,projectName)

%% PURPOSE: READ AN EXISTING TEXT FILE VARIABLE TO ISOLATE THE SPECIFIED PROJECT NAME & ASSOCIATED PATHS
% Inputs:
% text: Cell array where each element contains one line of text from the 'allProjects_ProjectNamesPaths.txt' file.
% projectName: Found in the very last line of the file, indicates which project was just being worked on.

numLines=length(text);
foundProject=0; % Initialize the project name to not be found.
logsheetPathPrefix='Logsheet Path:';
dataPathPrefix='Data Path:';
codePathPrefix='Code Path:';
rootSavePlotPathPrefix='Save Plot Root Path:';
for i=1:numLines
    if contains(text{i},'Project Name:') && contains(text{i},projectName) % This is the project name line
        foundProject=1; % Indicates that the project name was found.
    elseif foundProject==0
        continue;
    end
    
    if isempty(text{i})
        break; % Found the end of the project's path names.
    end
    
    % Now working in the correct project's lines of text
    if contains(text{i},logsheetPathPrefix) % Logsheet path
        projectNamesPaths.LogsheetPath=text{i}(length(logsheetPathPrefix)+2:length(text{i}));
    elseif contains(text{i},dataPathPrefix) % Data path
        projectNamesPaths.DataPath=text{i}(length(dataPathPrefix)+2:length(text{i}));
    elseif contains(text{i},codePathPrefix) % Code path
        projectNamesPaths.CodePath=text{i}(length(codePathPrefix)+2:length(text{i}));
    elseif contains(text{i},rootSavePlotPathPrefix) % Save plot root folder path.
        projectNamesPaths.RootSavePlotPath=text{i}(length(rootSavePlotPathPrefix)+2:length(text{i}));
    end
    
end

if ~exist('projectNamesPaths','var')
    projectNamesPaths=''; % Empty char for no path names being present.
end