function [G] = linkageToDigraph(links)

%% PURPOSE: CONVERT THE LINKAGE MATRIX TO A DIGRAPH (FUNCTIONS ONLY) SO THAT I CAN CHECK DEPENDENCIES.
% types: Indicates what types of objects to return in the digraph.
    % 'PR': Returns a digraph where the nodes are processing functions, and
    % the edges are the variables.
    % 'ALL': Returns all objects as a node, from variables to projects.
        % Allows for checking which objects are in which containers.

% Digraph fields:
    % Nodes:
        % Name: The UUID of the node.
        % PrettyName: The human-readable name of the node (non-unique).

if exist('links','var')~=1
    containerUUID = getCurrent('Current_Analysis');
    list = getUnorderedList(containerUUID);
    links = loadLinks(list);
end

% Remove everything except for functions and variables.
abbrevs1 = {'PR','LG'};
abbrevs2 = 'VR';

if isempty(links)   
    G = digraph();
    G.Nodes.PrettyEndNodes = {};
    G.Nodes.Name = cell(0, 1);
    G.Nodes.PrettyName = {};
    return;
end

% Exclude rows from the linkage matrix with only an output or input
% variable. What happens if an element in s or t is empty?
varsIdx = contains(links(:,2),abbrevs2) & (contains(links(:,1),abbrevs1) | contains(links(:,3),abbrevs1));

s = links(varsIdx,1); % The UUID of the PR that the variable is an output of.
t = links(varsIdx,3); % The UUID of the PR that the variable is an input to.

edgeNames = links(varsIdx,2);

prettyEdgeNames = getName(edgeNames);
edgeTable = table([s t],getName([s t]),edgeNames,prettyEdgeNames,'VariableNames',{'EndNodes','PrettyEndNodes','Name','PrettyName'});
G = digraph(edgeTable);
G.Nodes.PrettyName = getName(G.Nodes.Name);