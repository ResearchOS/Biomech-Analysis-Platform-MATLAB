function [] = unlinkObjs(leftObj, rightObj)

%% PURPOSE: UNLINK OBJECTS IN THE LINKAGE MATRIX.

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

newline = {leftObj, rightObj};
existIdx = ismember(links(:,1),newline{1}) & ismember(links(:,2),newline{2});

links(existIdx,:) = [];

writeJSON(linksFilePath,links);