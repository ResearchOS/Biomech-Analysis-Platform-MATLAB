function [groupNames,lineNums,mostRecentSetupGroupName,mostRecentRunGroupName]=getGroupNames(text)

%% PURPOSE: RETURN THE GROUP NAMES FROM THIS PROJECT'S FUNCTION NAMES FILE

% Inputs:
% text: The text of the function names file. Each line is one element (cell array)

% Outputs:
% groupNames: The group names for this project (cell array)
% lineNums: The line numbers in the text file where each group was found (vector of doubles, in same order as groupNames)
% mostRecentGroupName: The most recent group name, at the end of the file (char)

groupNames={''};
lineNums=[];
groupCount=0;

if isempty(text)
    
    mostRecentSetupGroupName=[];
    mostRecentRunGroupName=[];
    groupNames={'Create Group Name'};
    
end

for i=1:length(text)
    
    if length(text{i})>length('Group Name:') && isequal(text{i}(1:length('Group Name:')),'Group Name:') % If this line is a group name
        
        groupCount=groupCount+1;
        if groupCount==1
            groupNames={text{i}(13:length(text{i}))};
            lineNums=i;
        else
            groupNames=[groupNames; {text{i}(13:length(text{i}))}];
            lineNums=[lineNums; i];
        end
        
    end
    
    if length(text{i})>length('Most Recent Setup Group Name:') && isequal(text{i}(1:length('Most Recent Setup Group Name:')),'Most Recent Setup Group Name:')
        mostRecentSetupGroupName=text{i}(length('Most Recent Setup Group Name:')+2:length(text{i}));
    end
    
    if length(text{i})>length('Most Recent Run Group Name:') && isequal(text{i}(1:length('Most Recent Run Group Name:')),'Most Recent Run Group Name:')
        mostRecentRunGroupName=text{i}(length('Most Recent Run Group Name:')+2:length(text{i}));
    end
    
end