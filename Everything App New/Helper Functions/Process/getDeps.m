function [R, deps] = getDeps(G,dir,uuid)

%% PURPOSE: GET DOWNSTREAM OR UPSTREAM DEPENDENCIES OF ANY PR IN THE DIGRAPH.
% G: digraph
% dir: 'up', 'down'
%   'up': PR's before the source PR in the run list.
%   'down': PR's after the source PR in the run list.
% uuid: The node of interest, specified as UUID char (optional).

% Outputs:
% deps: The unordered list of PR's that the src/trg directly is depended on by/depends on

if nargin==1
    dir = 'down';
end

dir = upper(dir);

assert(ismember(dir,{'UP','DOWN'}));

if isequal(dir,'UP')
    G = flipedge(G); % Going upstream now.
end

H = transclosure(G);
% https://www.mathworks.com/help/matlab/ref/digraph.transclosure.html
% to answer the question "Which nodes are reachable from node 3?", you can look at the third row in the matrix
% number of rows & cols = number of nodes.
R = full(adjacency(H)); % "Reachability matrix"

deps = {};
if nargin==3
    uuidIdx = ismember(G.Nodes.Name, uuid);
    tmpIdx = logical(R(uuidIdx,:))'; % Make column vector.
    deps = G.Nodes.Name(tmpIdx); % The uuids reachable from this UUID        
end