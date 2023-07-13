function []=linkObjs(leftObj, rightObj)

%% PURPOSE: LINK TWO OBJECTS TOGETHER. INPUTS ARE THE STRUCTS THEMSELVES, OR THEIR UUID'S.
% LINKAGE INFORMATION IS STORED IN ITS OWN FILES, UNDER "LINKAGES" IN THE
% COMMON PATH.

slash = filesep;

if ~ischar(leftObj)
    leftObj = leftObj.UUID;
end

if ~ischar(rightObj)
    rightObj = rightObj.UUID;
end

linksFolder = [getCommonPath() slash 'Linkages'];
linksFilePath = [linksFolder slash 'Linkages.json'];

links = loadJSON(linksFilePath);

% IN THE ORDER THINGS WERE ADDED.
newline = {leftObj, rightObj};
existIdx = ismember(links(:,1),newline{1}) & ismember(links(:,2),newline{2});
if any(existIdx)
    if isequal(newline,links(existIdx,:)) % Redundant check
        return; % Don't do anything if the connection already exists.
    end
end

links = [links; newline]; % Append this link to the file.

writeJSON(linksFilePath, links);