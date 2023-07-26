function []=linkObjs(leftObjs, rightObjs, date)

%% PURPOSE: LINK TWO OBJECTS TOGETHER. INPUTS ARE THE STRUCTS THEMSELVES, OR THEIR UUID'S.
% LINKAGE INFORMATION IS STORED IN ITS OWN FILES, UNDER "LINKAGES" IN THE
% COMMON PATH.

slash = filesep;

if ischar(leftObjs)
    leftObjs = {leftObjs};
end

if ischar(rightObjs)
    rightObjs = {rightObjs};
end

if isstruct(leftObjs)
    leftObjs = {leftObjs.UUID};
end

if isstruct(rightObjs)
    rightObjs = {rightObjs.UUID};
end

if length(leftObjs)>1 && length(rightObjs)>1
    error('Either the left or right element must be scalar');
end

% Ensure that there are two lists of equal length.
if length(leftObjs)==1
    leftObjs = repmat(leftObjs,length(rightObjs),1);
end

if length(rightObjs)==1
    rightObjs = repmat(rightObjs,length(leftObjs),1);
end

assert(length(leftObjs)==length(rightObjs));

linksFolder = [getCommonPath() slash 'Linkages'];
linksFilePath = [linksFolder slash 'Linkages.json'];

links = loadJSON(linksFilePath);

for i=1:length(leftObjs)
    newline = {leftObjs{i}, rightObjs{i}};
    existIdx = ismember(links(:,1),newline{1}) & ismember(links(:,2),newline{2});
    if any(existIdx)
        if isequal(newline,links(existIdx,:)) % Redundant check
            continue; % Don't do anything if the connection already exists.
        end
    end

    links = [links; newline]; % Append this link to the file.
end

writeJSON(linksFilePath, links, date);