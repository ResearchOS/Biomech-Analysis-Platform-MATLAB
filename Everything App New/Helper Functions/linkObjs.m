function []=linkObjs(leftObjs, rightObjs, date)

%% PURPOSE: LINK TWO OBJECTS TOGETHER. INPUTS ARE THE STRUCTS THEMSELVES, OR THEIR UUID'S.
% LINKAGE INFORMATION IS STORED IN ITS OWN FILE, UNDER "LINKAGES" IN THE
% COMMON PATH.

slash = filesep;

if ischar(leftObjs)
    leftObjs = {leftObjs};    
end

if ischar(rightObjs)
    rightObjs = {rightObjs};
end

if isstruct(leftObjs)
%     leftObjsStruct = leftObjs;
    % When do I need to update the left object as being out of date?
    leftObjs = {leftObjs.UUID};
end

if isstruct(rightObjs)
%     rightObjsStruct = rightObjs;
    % When do I need to update the right object as being out of date?
    rightObjs = {rightObjs.UUID};
end

%% Update the "OutOfDate" field
% No need to update the left object when it's just a variable being added as an input somewhere.
% if ~all(contains(leftObjs,{'VR','AN','PG'}))
%     for i=1:length(leftObjs)
%         recurseSetOutOfDate(leftObjs{i}, true); % Recursively set the "OutOfDate" field to be true for all dependencies!
%         leftObjsStruct = loadJSON(leftObjs{i});
%         leftObjsStruct.OutOfDate = true;
%         writeJSON(getJSONPath(leftObjsStruct), leftObjsStruct);
%     end
% end
% 
% for i=1:length(rightObjs)
%     rightObjsStruct = loadJSON(rightObjs{i});
%     rightObjsStruct.OutOfDate = true;
%     writeJSON(getJSONPath(rightObjsStruct), rightObjsStruct);
% end


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
    if any(existIdx)
        if isequal(newline,links(existIdx,:)) % Redundant check
            continue; % Don't do anything if the connection already exists.
        end
    end

    links = [links; newline]; % Append this link to the file.
end

if nargin==3
    writeJSON(linksPath, links, date);
else
    writeJSON(linksPath, links);
end