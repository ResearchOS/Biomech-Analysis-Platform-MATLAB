function [argNames,argsNamesInCode,argsDesc]=getAllArgNames(text,projectName,guiTab,groupName,fcnName)

%% PURPOSE: RETURN ALL ARGUMENT NAMES FOR THE CURRENT GUI TAB
% Inputs:
% text: The body of the text file (cell array of chars, each cell is one line)
% projectName: The current project name (char)
% guiTab: The current tab of the GUI for which this args function was opened (char)
% groupName: (optional) Look for args within a function within this group (char)
% fcnName: (optional) Look for args within this function. Includes method number & letter (char)

% Leave groupName and fcnName unspecified when collecting all args to populate the 'All' list. Specify them to populate a specific function's list.

argNames={};
argsNamesInCode={};
argsDesc={};
projectFound=0;
groupFound=0;
fcnFound=0;

argCount=0;

for i=1:length(text)

    if projectFound==0 && length(text{i})>=length(['Project Name: ' projectName]) && isequal(text{i}(1:length(['Project Name: ' projectName])),['Project Name: ' projectName])
        projectFound=1;
        continue;
    end

    if projectFound==0
        continue;
    end

    if length(text{i})>=length('Project Name:') && isequal(text{i}(1:length('Project Name:')),'Project Name:') % Another project was found after this one. Current project has ended.
        break;
    end    

    if ~exist('groupName','var') && ~exist('fcnName','var') % Args from all functions and groups within a project.
        if length(text{i})>=length('Group Name: ') && isequal(text{i}(1:length('Group Name: ')),'Group Name: ')
            continue;
        end
        if length(text{i})>=length('Function Name: ') && isequal(text{i}(1:length('Function Name: ')),'Function Name: ')
            continue;
        end        
        colonIdx=strfind(text{i},':');
        if isempty(text{i})
            continue;
        end
        argCount=argCount+1;
        argNames{argCount}=strtrim(text{i}(colonIdx(1)+1:colonIdx(2)-1)); % Get argument name        
        continue;
    end

    if exist('groupName','var') && length(text{i})>=length(['Group Name: ' groupName]) && isequal(text{i}(1:length(['Group Name: ' groupName])),['Group Name: ' groupName])
        groupFound=1;
        continue;
    end

    if groupFound==0
        continue;
    end

    if exist('fcnName','var') && length(text{i})>=length(['Function Name: ' fcnName]) && isequal(text{i}(1:length(['Function Name: ' fcnName])),['Function Name: ' fcnName])
        fcnFound=1;
        continue;
    end

    if ~(length(text{i})>=length(guiTab) && isequal(text{i}(1:length(guiTab)),guiTab))
        continue; % If this argument name is not from the proper GUI tab, skip it.
    end

    if fcnFound==0
        continue;
    end

    % Args specific to one function within one group.    
    colonIdx=strfind(text{i},':');
    if isempty(text{i})
        continue;
    end
    argCount=argCount+1;
    argNames{argCount}=strtrim(text{i}(colonIdx(1)+1:colonIdx(2)-1)); % Get argument name
    argsNamesInCode{argCount}=strtrim(text{i}(colonIdx(2)+1:colonIdx(3)-1)); % Get the name in code
    argsDesc{argCount}=strtrim(text{i}(colonIdx(3)+1:end)); % Get the description

end

argNames=sort(unique(argNames));