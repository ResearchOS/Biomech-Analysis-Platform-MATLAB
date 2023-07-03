function []=linkObjs(leftObj, rightObj)

%% PURPOSE: LINK TWO OBJECTS TOGETHER. INPUTS ARE THE STRUCTS THEMSELVES, OR THEIR UUID'S.
% LINKAGE INFORMATION IS STORED IN ITS OWN FILES, UNDER "LINKAGES" IN THE
% COMMON PATH.

if ischar(leftObj)
    leftObj = loadJSON(leftObj);
end

if ischar(rightObj)
    rightObj = loadJSON(rightObj);
end

linksFolder = [commonPath slash 'Linkages'];
linksFilePath = [linksFolder slash 'Linkages.json'];

links = loadJSON(linksFilePath);

projectName = getCurrent('Current_Project_Name');
analysisName = getCurrent('Current_Analysis_Name');

% THE ORDER THINGS ARE ADDED IN.
newline = {projectName analysisName leftObj.UUID rightObj.UUID};

links.Links = [links.Links; newline]; % Append this link to the file.

analysisIdx = sort(links.Links(:,2)); % Sort by analysis
links.Links = links.Links(analysisIdx,:);

projectIdx = sort(links.Links(:,1)); % Sort by project
links.Links = links.Links(projectIdx,:);

writeJSON(linksFilePath, links);