function []=generateLog(fig,nodeNum)

%% PURPOSE: GENERATE A RUNNING LOG OF ALL FUNCTIONS THAT RAN WITHOUT ERROR. ONE FILE PER DAY
% Inputs:
% fig: The pgui object (graphics object)
% nodeNum: The node number of the current function (double)

%% 1. Get the node's metadata:
% function name
% specify trials
% level

%% 2. If there is no file for today, create it.
currDate=char(datetime('now'));
currDate=currDate(1:11);

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

logFolder=[getappdata(fig,'codePath') 'Running Log'];

if ~isfolder(logFolder)
    mkdir(logFolder);
end

todaysFile=[logFolder slash projectName '_' currDate '.m']; % Potentially a project name length issue, but unlikely

if exist(todaysFile,'file')~=2
    templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'runningLogTemplate.m'];
    createFileFromTemplate(templatePath,todaysFile,[projectName '_' currDate]);
end

%% 3. Append to today's file the current node's run info.