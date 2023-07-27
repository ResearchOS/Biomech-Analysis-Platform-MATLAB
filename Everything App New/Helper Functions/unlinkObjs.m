function [] = unlinkObjs(leftObjs, rightObjs)

%% PURPOSE: UNLINK OBJECTS IN THE LINKAGE MATRIX.

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

if isempty(leftObjs{1}) || isempty(rightObjs{1})
    error('Why is a left or right object linkage empty?!')
    return;
end

[links, linksPath] = loadLinks();

for i=1:length(leftObjs)
    newline = {leftObjs{i}, rightObjs{i}};
    existIdx = ismember(links(:,1),newline{1}) & ismember(links(:,2),newline{2});

    links(existIdx,:) = [];
end

writeJSON(linksPath,links);