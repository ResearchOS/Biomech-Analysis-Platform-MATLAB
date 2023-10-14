function [node, cont]=getNode(parent, uuid, node, cont)

%% PURPOSE: OPERATES RECURSIVELY. RETURN THE NODE OBJECT SPECIFIED BY UUID IN THE GIVEN UITREE (RECURSIVE)
% UUID'S STORED IN "node.NodeData.UUID"

struct.UUID = uuid;
node = findobj(parent, 'NodeData', struct);

% if exist('cont','var')~=1
%     cont = true;
% elseif ~cont
%     return;
% end
% 
% if exist('node','var')~=1
%     node = [];
% end
% 
% children = parent.Children;
% 
% if isempty(children)    
%     return;
% end
% 
% tmp = [children.NodeData];
% uuids = {tmp.UUID};
% 
% nodeIdx = ismember(uuids,uuid);
% 
% if any(nodeIdx)
%     assert(sum(nodeIdx)==1); % 1 and only 1
%     node = children(nodeIdx);
%     cont = false;
%     return;
% end
% 
% for i=1:length(children)
%     child = children(i);
%     [node, cont] = getNode(child, uuid, node, cont);
% 
%     if ~cont
%         return; % Get back up to the top level
%     end
% end