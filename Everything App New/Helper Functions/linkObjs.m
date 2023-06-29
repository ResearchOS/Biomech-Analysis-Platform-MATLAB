function []=linkObjs(leftObj, rightObj)

%% PURPOSE: LINK TWO OBJECTS TOGETHER. INPUTS ARE THE STRUCTS THEMSELVES, OR THEIR UUID'S.
% LINKAGE INFORMATION IS STORED IN ITS OWN FILES, UNDER "LINKAGES" IN THE
% COMMON PATH.

if ischar(leftObj)
    leftObj = loadJSON(getJSONPath(leftObj));
end

if ischar(rightObj)
    rightObj = loadJSON(getJSONPath(rightObj));
end

linksFolder = [commonPath slash 'Linkages'];
if isequal(leftObj.Class,'Analysis') && isequal(rightObj.Class,'Project')   
    linksFilePath = [linksFolder slash 'Projects_Analyses.json'];
    links = loadJSON(linksFilePath);
else
    Current_Project_Name = load(rootSettingsFile,'Current_Project_Name');
    projectStruct = loadJSON(getJSONPath(Current_Project_Name));
    Current_Analysis = projectStruct.Current_Analysis;
    linksFilePath = [linksFolder slash Current_Analysis '.json'];
    links = loadJSON(linksFilePath);
end

links.Links = [links.Links; {leftObj.UUID rightObj.UUID}]; % Append this link to the file.

writeJSON(linksFilePath, links);