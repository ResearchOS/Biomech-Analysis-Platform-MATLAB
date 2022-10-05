function []=fcnsRunOrderFieldValueChanged(src,orderNum)

%% PURPOSE: CHANGE THE ORDER IN WHICH THE FUNCTIONS ARE RUN.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('edgeNum','var')~=1
    runLog=true;
    orderNum=handles.Process.fcnsRunOrderField.Value;
else
    handles.Process.fcnsRunOrderField.Value=orderNum;
    runLog=false;
end

if isempty(handles.Process.splitsUITree.SelectedNodes)
    disp('Need to select a split first!');
    handles.Process.fcnsRunOrderField.Value=0;
    return;
end

splitName_Code=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(splitName_Code,' ');
splitCode=splitName_Code(spaceIdx+2:end-1);
splitName=splitName_Code(1:spaceIdx-1);
selNode=handles.Process.fcnArgsUITree.SelectedNodes;

if isempty(selNode)
    disp('Must have a function selected!');
    handles.Process.fcnsRunOrderField.Value=0;
    return;
end

nodeNum=selNode.NodeData;
if isempty(nodeNum)
    disp('Must select a function name in the fcnArgsUITree!');
%     handles.Process.fcnsRunOrderField.Value=0;
    return;
end

numSelNodes=length(handles.Process.fcnArgsUITree.Children);

if numSelNodes>1
    disp('Can only select one node at a time!');
    return;
end

Digraph=getappdata(fig,'Digraph');

% Get the unique index of the desired edge.
% edgeIdx=ismember(Digraph.Edges.SplitCode,splitCode) & ismember(Digraph.Edges.NodeNumber(:,2),nodeNum);
nodeRow=find(ismember(Digraph.Nodes.NodeNumber,nodeNum)==1);

prevOrderNum=Digraph.Nodes.RunOrder{nodeRow}.([splitName '_' splitCode]);

if orderNum==prevOrderNum
    return;
end

Digraph.Nodes.RunOrder{nodeRow}.([splitName '_' splitCode])=orderNum;

% inNodes=inedges(Digraph,nodeRow);
% outNodes=outedges(Digraph,nodeRow);
% 
% if ~(length(inNodes)==1 && length(outNodes)==1)
%     setappdata(fig,'Digraph',Digraph);
% 
%     if runLog
%         desc='Change the order in which the functions are run';
%         updateLog(fig,desc,orderNum);
%     end
%     return;
% end

%% Propagate the change to the fcn run order
isUnique=true; % Indicate that there is only one inedge and one outedge for this split
while isUnique

    nodeID=Digraph.Nodes.NodeNumber(nodeRow);

    edgeRows=ismember(Digraph.Edges.NodeNumber(:,1),nodeID);

%     nodeRow=outedges(Digraph,nodeRow); % The node just after the current node
    if isempty(edgeRows)
        isUnique=0;
        break;
    end

%     edgeRows=find(ismember(Digraph.Edges.EndNodes(:,2),nodeRow)==1); % The rows of the edges coming out of the current node

    edgeRowsCurrSplit=ismember(Digraph.Edges.SplitCode,splitCode);
    currEdgeRowsCurrSplit=edgeRowsCurrSplit & edgeRows; % The rows in the current split that are outedges of the current node.
    if sum(currEdgeRowsCurrSplit)~=1 % Either there are no edges of the current split, or there are more than one.
        isUnique=0;
        break;
    end   

    nextNodeID=Digraph.Edges.NodeNumber(currEdgeRowsCurrSplit,2);
    nextNodeRow=ismember(Digraph.Nodes.NodeNumber,nextNodeID);
        
    orderNum=orderNum+1;
    Digraph.Nodes.RunOrder{nextNodeRow}.([splitName '_' splitCode])=orderNum;

    nodeRow=find(nextNodeRow==1);

end


% save(projectSettingsMATPath,'Digraph','-append');
setappdata(fig,'Digraph',Digraph);

if runLog
    desc='Change the order in which the functions are run';
    updateLog(fig,desc,orderNum);
end