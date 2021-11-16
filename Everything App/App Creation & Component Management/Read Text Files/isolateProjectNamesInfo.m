function [projectNamesInfo]=isolateProjectNamesInfo(text,projectName)

%% PURPOSE: READ AN EXISTING TEXT FILE VARIABLE TO ISOLATE THE SPECIFIED PROJECT NAME & ASSOCIATED INFO
% Inputs:
% text: Cell array where each element contains one line of text from the 'allProjects_ProjectNamesPaths.txt' file.
% projectName: Found in the very last line of the file, indicates which project was being worked on most recently.

%% LIST OF INFO STORED FOR EACH PROJECT:
% Logsheet Path:
% Data Path:
% Code Path:
% Root Save Plot Path:
% Number of Header Rows:
% Subject ID Column Header:
% Trial ID Column Header:
% Trial ID Format:
% Target Trial ID Format:
% Groups' Data To Load:

numLines=length(text);
foundProject=0; % Initialize the project name to not be found.
logsheetPathPrefix='Logsheet Path:';
dataPathPrefix='Data Path:';
codePathPrefix='Code Path:';
rootSavePlotPathPrefix='Save Plot Root Path:';
numHeaderRowsPrefix='Number of Header Rows:';
subjIDColHeaderPrefix='Subject ID Column Header:';
trialIDColHeaderPrefix='Trial ID Column Header:';
trialIDFormatPrefix='Trial ID Format:';
targetTrialIDFormatPrefix='Target Trial ID Format:';
groupsDataToLoadPrefix='Groups Data To Load:';
for i=1:numLines
    
    if isempty(text{i})
        if foundProject==1
            break; % Found the end of the project's path names.
        elseif foundProject==0
            continue;
        end
    end
    
    if isequal(text{i}(1:length('Project Name:')),'Project Name:') && isequal(text{i}(length('Project Name:')+2:length('Project Name:')+1+length(projectName)),projectName) % This is the project name line
        foundProject=1; % Indicates that the project name was found.
    elseif foundProject==0
        continue;
    end        
    
    % Now working in the correct project's lines of text
    if length(text{i})>=length(logsheetPathPrefix) && isequal(text{i}(1:length(logsheetPathPrefix)),logsheetPathPrefix) % Logsheet path
        projectNamesInfo.LogsheetPath=text{i}(length(logsheetPathPrefix)+2:length(text{i}));
    elseif length(text{i})>=length(dataPathPrefix) && isequal(text{i}(1:length(dataPathPrefix)),dataPathPrefix) % Data path
        projectNamesInfo.DataPath=text{i}(length(dataPathPrefix)+2:length(text{i}));
    elseif length(text{i})>=length(codePathPrefix) && isequal(text{i}(1:length(codePathPrefix)),codePathPrefix) % Code path
        projectNamesInfo.CodePath=text{i}(length(codePathPrefix)+2:length(text{i}));
    elseif length(text{i})>=length(rootSavePlotPathPrefix) && isequal(text{i}(1:length(rootSavePlotPathPrefix)),rootSavePlotPathPrefix) % Save plot root folder path.
        projectNamesInfo.RootSavePlotPath=text{i}(length(rootSavePlotPathPrefix)+2:length(text{i}));
    elseif length(text{i})>=length(numHeaderRowsPrefix) && isequal(text{i}(1:length(numHeaderRowsPrefix)),numHeaderRowsPrefix) % Number of header rows in logsheet
        projectNamesInfo.NumHeaderRows=str2double(text{i}(length(numHeaderRowsPrefix)+2:length(text{i})));
    elseif length(text{i})>=length(subjIDColHeaderPrefix) && isequal(text{i}(1:length(subjIDColHeaderPrefix)),subjIDColHeaderPrefix) % Subject ID column header
        projectNamesInfo.SubjIDColHeader=text{i}(length(subjIDColHeaderPrefix)+2:length(text{i}));
    elseif length(text{i})>=length(trialIDColHeaderPrefix) && isequal(text{i}(1:length(trialIDColHeaderPrefix)),trialIDColHeaderPrefix) % Trial ID column header
        projectNamesInfo.TrialIDColHeader=text{i}(length(trialIDColHeaderPrefix)+2:length(text{i}));
    elseif length(text{i})>=length(trialIDFormatPrefix) && isequal(text{i}(1:length(trialIDFormatPrefix)),trialIDFormatPrefix) % Trial ID format
        projectNamesInfo.TrialIDFormat=text{i}(length(trialIDFormatPrefix)+2:length(text{i}));
    elseif length(text{i})>=length(targetTrialIDFormatPrefix) && isequal(text{i}(1:length(targetTrialIDFormatPrefix)),targetTrialIDFormatPrefix) % Target trial ID format
        projectNamesInfo.TargetTrialIDFormat=text{i}(length(targetTrialIDFormatPrefix)+2:length(text{i}));
    elseif length(text{i})>=length(groupsDataToLoadPrefix) && isequal(text{i}(1:length(groupsDataToLoadPrefix)),groupsDataToLoadPrefix) % Groups' data to load.
        projectNamesInfo.GroupsDataToLoad=text{i}(length(groupsDataToLoadPrefix)+2:length(text{i}));
    end
    
end

if ~exist('projectNamesInfo','var')
    projectNamesInfo=''; % Empty char for no path names being present.
end