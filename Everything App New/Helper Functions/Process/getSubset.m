function [currLinks] = getSubset(nodeMatrix, analysis)

%% PURPOSE: GET THE SUBSET OF LINKAGES THAT BELONG TO THE CURRENT ANALYSIS.

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