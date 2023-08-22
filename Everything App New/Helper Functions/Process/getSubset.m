function [delFcns] = getSubset(nodeMatrix, analysis)

%% PURPOSE: GET THE SUBSET OF LINKAGES THAT BELONG TO THE CURRENT ANALYSIS.

% 1. Flip the source & target nodes so that everything starts with
% "projects".
G = digraph(nodeMatrix(:,2), nodeMatrix(:,1));

delIdx = [];
for i=1:length(nodeMatrix(:,1))
    if ~isequal(deText(nodeMatrix{i,1}),'PR')
        continue; % Looking at Process functions only.
    end

    if ~isempty(shortestpath(G, analysis, nodeMatrix(i,1)))
        continue; % There is a path.
    end
    delIdx = [delIdx; i];
end

delFcns = nodeMatrix(delIdx,1);

% 2. For all nodes, if there's a path between the analysis & the function,
% it's part of the analysis.

% 3. Remove all functions that aren't part of the analysis (in a different
% function?)

% 1. Get the list of nodes that have no input AND are contained in the current analysis.


% 2. Connect a new node called "START" to all of those nodes.

% 3. Get the list of nodes that have no output.

% 4. Connect a new node called "END" to all of those nodes.

% if exist('links','var')~=1
%     slash = filesep;
%     linksFolder = [getCommonPath() slash 'Linkages'];
%     linksFilePath = [linksFolder slash 'Linkages.json'];
% 
%     links = loadJSON(linksFilePath);
% end
% 
% if exist('currLinks','var')~=1
%     currLinks = {};
% end
% 
% idx = ismember(links(:,2),rightName);
% 
% if ~any(idx)
%     return;
% end
% 
% subLinks = links(idx,:);
% 
% for i=1:size(subLinks,1)
%     
%     currLinks = getSubset(subLinks(i,1),links,subLinks);
%     currLinks = [currLinks; subLinks(i,:)];
% 
% end