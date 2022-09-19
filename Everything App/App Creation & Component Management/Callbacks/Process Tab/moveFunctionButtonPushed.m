function []=moveFunctionButtonPushed(src,event)

%% PURPOSE: MOVE SELECTED FUNCTIONS TO NEW LOCATION BY SPECIFYING OFFSET
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Digraph=getappdata(fig,'Digraph');

allNodes=handles.Process.fcnArgsUITree.Children;

if isempty(allNodes)
    disp('Need to select a node first!');
    return;
end

nodeNums=[allNodes.NodeData];

nodeRows=ismember(Digraph.Nodes.NodeNumber,nodeNums);

% coords=Digraph.Nodes.Coordinates(nodeRows,:);

a=input('Enter offset as "# #": ');

if isempty(a)
    return;
end

if ~ischar(a)
    disp('Must be a character!');
    return;
end

if isempty(isspace(a))
    disp('Must enter two numbers!');
    return;
end

a=strsplit(a,' ');

offset(1)=str2double(a{1});
offset(2)=str2double(a{2});

Digraph.Nodes.Coordinates(nodeRows,:)=Digraph.Nodes.Coordinates(nodeRows,:)+offset;

delete(handles.Process.mapFigure.Children);
h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.447 0.741],'Interpreter','none');
h.EdgeColor=Digraph.Edges.Color;

setappdata(fig,'Digraph',Digraph);

highlightedFcnsChanged(fig,Digraph);