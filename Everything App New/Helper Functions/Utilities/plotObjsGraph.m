function [] = plotObjsGraph(G)

%% PURPOSE: PLOT THE GRAPH WITH ALL NODES AS ALL OBJECTS.
close all;
Q = figure;
hold on;

if nargin==0 || isempty(G)
    G = getAllObjLinks();
end

prettyNames = getName(G.Nodes.Name);

idx = cellfun(@isnumeric, prettyNames);
prettyNames(idx) = G.Nodes.Name(idx);

% types = getTypes();

colors = repmat([0 0 0], length(G.Nodes.Name),1);
nodeColors.LG = 'grass green';
nodeColors.ST = 'light brown';
nodeColors.VR = 'red';
nodeColors.AN = 'dark yellow';
nodeColors.PJ = 'purple';
nodeColors.VW = 'sky blue';
nodeColors.PG = 'orange';
nodeColors.PR = 'dark brown';

% labels = fieldnames(nodeColors);
types = unique(deText(G.Nodes.Name),'stable');
for i=1:length(types)
    h(i) = scatter(NaN,NaN,10,rgb(nodeColors.(types{i})),'filled');
end
legend(types,'AutoUpdate','off');

h = plot(G, 'NodeLabel',prettyNames,'Interpreter','None');

for i=1:length(types)
    idx = contains(G.Nodes.Name,types{i});
    colors(idx,:) = repmat(rgb(nodeColors.(types{i})),sum(idx),1);
end

h.NodeColor = colors;
h.MarkerSize = 8;