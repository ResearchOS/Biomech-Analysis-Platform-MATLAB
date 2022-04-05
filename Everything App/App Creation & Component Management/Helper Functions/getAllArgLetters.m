function [fcnLetters]=getAllArgLetters(text,projectName,guiTab,fcnName,methodNum)

%% PURPOSE: RETURN ALL ARGUMENT LETTERS FOR THE CURRENT FUNCTION NAME & NUMBER
% Inputs:
% text: The body of the text file (cell array of chars, each cell is one line)
% projectName: The current project name (char)
% guiTab: The current tab of the GUI for which this args function was opened (char)
% groupName: (optional) Look for args within a function within this group (char)
% fcnName: (optional) Look for args within this function. Does NOT include method number & letter (char)

% Leave groupName and fcnName unspecified when collecting all args to populate the 'All' list. Specify them to populate a specific function's list.

fcnLetters={};
projectFound=0;
fcnCount=0;

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

%     if ~(length(text{i})>=length(guiTab) && isequal(text{i}(1:length(guiTab)),guiTab))
%         continue; % If this argument name is not from the proper GUI tab, skip it.
%     end

    if length(text{i})>=length(['Function Name: ' fcnName '_' guiTab methodNum]) && isequal(text{i}(1:length(['Function Name: ' fcnName '_' guiTab methodNum])),['Function Name: ' fcnName '_' guiTab methodNum])
        fcnCount=fcnCount+1;
        fcnLetters{fcnCount}=strtrim(text{i}(length(['Function Name: ' fcnName '_' guiTab methodNum])+1:end));
    end

end

fcnLetters=sort(unique(fcnLetters));