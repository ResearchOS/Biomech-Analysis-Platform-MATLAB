function []=highlightedFcnsChanged(src,Digraph)

%% PURPOSE: MODIFY THE GUI WITH THE CURRENTLY SELECTED FUNCTIONS' VARIABLES IN fcnArgsUITree
% Inputs:
% src:
% Digraph:
% selNodeNum: The node number for the selected function in the
% fcnArgsUITree. If not entered, use the first function.

if isempty(Digraph.Edges)
    return;
end

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

delete(handles.Process.fcnArgsUITree.Children);

selNodeIDs=getappdata(fig,'selectedNodeNumbers'); % From the figure

%% NOTE: HERE I NEED TO ORDER THE SELECTED FUNCTIONS, BASED ON INEDGES & OUTEDGES (IN THE FUTURE THIS SHOULD BE SYNONYMOUS WITH RUN ORDER AS THAT IS MORE AUTOMATICALLY SET)
if isempty(handles.Process.splitsUITree.SelectedNodes)
    disp('Select a split first!');
    return;
end

currSplit=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(currSplit,' ');
splitName=currSplit(1:spaceIdx-1);
splitCode=currSplit(spaceIdx+2:end-1);
% [nodeRows,a,b]=intersect(Digraph.Nodes.NodeNumber,selNodeIDs);
nodeRows=ismember(Digraph.Nodes.NodeNumber,selNodeIDs);
nodeRowsNums=find(nodeRows==1);
if isequal(nodeRowsNums,1)
    handles.Process.fcnsRunOrderField.Value=0;
    return;
end
nodeRowsNums=nodeRowsNums(~ismember(nodeRowsNums,1)); % Remove the logsheet, if it's been selected.
runOrders=Digraph.Nodes.RunOrder(nodeRows);
runOrderNums=NaN(size(runOrders));
count=0;
for i=1:length(runOrderNums)
    inEdgesRows=ismember(Digraph.Edges.EndNodes(:,2),nodeRowsNums(i)); % All inedges for the current function
    outEdgesRows=ismember(Digraph.Edges.EndNodes(:,1),nodeRowsNums(i)); % All outedges for the current function
    splitCodes=Digraph.Edges.SplitCode(inEdgesRows | outEdgesRows);
    if ~isstruct(runOrders{i})
        continue;
    end
    if ismember(splitCode,splitCodes)
        count=count+1;
        runOrderNums(count)=runOrders{i}.([splitName '_' splitCode]);
    end
end
runOrderNums=runOrderNums(~isnan(runOrderNums));
if isempty(runOrderNums) && ~(isempty(nodeRows) || ~any(nodeRows))
    disp('No selected nodes are in the current split!');
    return;
end
[~,sortIdx]=sort(runOrderNums);

nodeRowsNums=nodeRowsNums(sortIdx); % The node row numbers, IN ORDER OF RUN ORDER
nodesData=Digraph.Nodes.NodeNumber(nodeRowsNums);

% Visually highlight all selected nodes
plotH=findobj(handles.Process.mapFigure,'Type','GraphPlot');
nodeSizes=plotH.MarkerSize;
if isequal(size(nodeSizes),[1 1])
    nodeSizes=repmat(nodeSizes,length(nodeRows),1);
end

nodeSizes(nodeRowsNums)=8;
nodeSizes(1)=4;
if ~isempty(nodeRowsNums)
    try
        plotH.MarkerSize=nodeSizes;
    catch
        plotH.MarkerSize=4;
    end
else
    plotH.MarkerSize=4;
end

nodeColors=plotH.NodeColor;
if isequal(size(nodeColors,1),1)
    nodeColors=repmat(nodeColors,length(nodeRows),1);
end
nodeColors(nodeRowsNums,:)=repmat([0 0 0],length(nodeRowsNums),1);
nodeColors(1,:)=[0 0.447 0.741];
if ~isempty(nodeRowsNums)
    plotH.NodeColor=nodeColors;
else
    plotH.NodeColor=[0 0.447 0.741];
end

% Get the index in the inputVariableNames of the current split. For
% that, need split code corresponding to the current split name
if isempty(handles.Process.splitsUITree.SelectedNodes)
    handles.Process.splitsUITree.SelectedNodes=handles.Process.splitsUITree.Children(1);
end
text=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(text,' ');
splitName=text(1:spaceIdx-1);
splitCode=text(spaceIdx+2:end-1); % Currently selected split.

% Do checks to ensure that the pre-conditions are properly met.
for i=1:length(nodeRowsNums)
    inEdgesRows=ismember(Digraph.Edges.EndNodes(:,2),nodeRowsNums(i)); % All inedges for the current function
    outEdgesRows=ismember(Digraph.Edges.EndNodes(:,1),nodeRowsNums(i)); % All outedges for the current function
    if isempty(inEdgesRows) && isempty(outEdgesRows)
        beep;
        disp('Need to connect this function to another before selecting it.');
        return;
    end

    % Check which splits the inedges and outedges belong to, to determine
    % whether this node is connected to the current split (instead of
    % looking at the input variable names, which may not perfectly reflect
    % that)
    if ~ismember(splitCode,Digraph.Edges.SplitCode(inEdgesRows | outEdgesRows))
        disp(['Function ' Digraph.Nodes.FunctionNames{nodeRowsNums(i)} ' Not Connected to Split ' splitName ' (' splitCode ')']);        
%         disp(['All selected functions need to be connected to the selected split!']);
        beep;
        delete(handles.Process.fcnArgsUITree.Children);
        h=findobj(handles.Process.mapFigure,'Type','GraphPlot');
        delete(h);
        h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.447 0.741],'Interpreter','none');
        if ~isempty(Digraph.Edges)
            h.EdgeColor=Digraph.Edges.Color;
        end
        return;
    end
end

% projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'NonFcnSettingsStruct');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');

% Get the list of splits from bottom to top in the splitsUITree
currSplitNode=handles.Process.splitsUITree.SelectedNodes;
splitsList={};
while ~isequal(class(currSplitNode),'matlab.ui.container.CheckBoxTree')
    splitText=currSplitNode.Text;
    spaceIdx=strfind(splitText,' ');
    splitName=splitText(1:spaceIdx-1);
    splitsList=[splitName; splitsList];
    currSplitNode=currSplitNode.Parent;
end

splitsStruct=NonFcnSettingsStruct.Process.Splits;
for i=1:length(splitsList)
    splitsStruct=splitsStruct.SubSplitNames.(splitsList{i});
end
splitColor=splitsStruct.Color;
edgeIdx=find(ismember(Digraph.Edges.Color,splitColor,'rows')==1);
h=findobj(handles.Process.mapFigure,'Type','GraphPlot');
highlight(h,'Edges',1:size(Digraph.Edges.Color,1),'LineWidth',0.5); % Reset line widths.
highlight(h,'Edges',edgeIdx,'LineWidth',2); % Emphasize the current split.

% Fill in the functions UI tree
keepNodesDataIdx=nodesData~=1; % Removes the logsheet node
nodesData=nodesData(keepNodesDataIdx);
splitName=splitsList{end};
for i=1:length(nodeRowsNums) % Each function    

    fcnName=uitreenode(handles.Process.fcnArgsUITree,'Text',Digraph.Nodes.FunctionNames{nodeRowsNums(i)},'NodeData',nodesData(i));
    fcnName.ContextMenu=handles.Process.openFcnContextMenu;
    inputs=uitreenode(fcnName,'Text','Inputs');

    currInVarNames=Digraph.Nodes.InputVariableNames{nodeRowsNums(i)};
    if isstruct(currInVarNames) && isfield(currInVarNames,[splitName '_' splitCode])
        currInVarNames=currInVarNames.([splitName '_' splitCode]);
    else
        currInVarNames={};
    end

    for j=1:length(currInVarNames)                
        uitreenode(inputs,'Text',currInVarNames{j},'ContextMenu',handles.Process.openFcnContextMenu);
    end

    currOutVarNames=Digraph.Nodes.OutputVariableNames{nodeRowsNums(i)};
    if isstruct(currOutVarNames) && isfield(currOutVarNames,[splitName '_' splitCode])
        currOutVarNames=currOutVarNames.([splitName '_' splitCode]);
    else
        currOutVarNames={};
    end

    outputs=uitreenode(fcnName,'Text','Outputs');
    for j=1:length(currOutVarNames)        
        uitreenode(outputs,'Text',currOutVarNames{j});
    end

    if i==1 && exist('selNodeNum','var')==0
        handles.Process.fcnArgsUITree.SelectedNodes=fcnName;
    end

    if exist('selNodeNum','var')==1
        handles.Process.fcnArgsUITree.SelectedNodes=fcnName;
    end

end

functionsUITreeSelectionChanged(fig);