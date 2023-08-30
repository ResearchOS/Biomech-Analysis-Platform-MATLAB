function [orderedList, listPR_PG_AN] = getRunList(containerUUID, arg2)

%% PURPOSE: GET THE LIST OF ITEMS TO RUN IN THE UUID SPECIFIED (ANALYSIS OR PROCESS GROUP)
% containerUUID: Char UUID of the container that we want the PR within.
% arg2: Any of the inputs required for any of the steps 2 onward. Each
% step's input is distinguished by its size and/or type.
% tic;
assert(ischar(containerUUID));

% Step 1
if nargin==1
    listPR_PG_AN = getUnorderedList(containerUUID); % Returns list with PR, PG, and AN types.

    if isempty(listPR_PG_AN)
        orderedList = {};
        return;
    end

    arg2 = {};
end

% Step 2: N x 2 cell array of PR in column 1, PG & AN in column 2
if isequal(size(arg2,2),2) && ~isa(arg2,'digraph')
    listPR_PG_AN = arg2;    
end
if exist('listPR_PG_AN','var')==1
    links = loadLinks(listPR_PG_AN); % Convert unordered list of processing functions into a linkage table.
end

% Step 3: N x 3 cell array of PR in column 1, VR in column 2, PR in column 3
if isequal(size(arg2,2),3) && ~isa(arg2,'digraph')
    links = arg2;    
end
if exist('links','var')
    G = linkageToDigraph(links);
end

% Step 4: Digraph
if isa(arg2,'digraph')
    G = arg2;
end

% Always executed no matter what arg2 is.
% H = transclosure(G);
% R = full(adjacency(H)); % "Reachability matrix"
% sumR = sum(R,2);
% [sortSumR,k] = sort(sumR,1,'descend');
% orderedList = [G.Nodes.Name(k), num2cell(sortSumR)]; % Changes the criteria to "maxNum" from "minNum"
orderedList = orderDeps(G,'full'); % All PR. Need to convert this to parent objects.

if exist('listPR_PG_AN','var')==1
    inListIdx = ismember(orderedList(:,1),listPR_PG_AN(:,1)); % Only the PR in the current container
    assert(all(inListIdx)); % Why would this ever not be true, if getUnorderedList only looks in the current container?
    orderedList(~inListIdx,:) = [];
end

% a = toc;
disp(['Run list in ' num2str(round(a,2)) 'sec']);

end