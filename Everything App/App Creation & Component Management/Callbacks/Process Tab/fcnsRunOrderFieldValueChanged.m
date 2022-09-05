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

% fcnName=selNode.Text;

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');

% Get the unique index of the desired edge.
% edgeIdx=ismember(Digraph.Edges.SplitCode,splitCode) & ismember(Digraph.Edges.NodeNumber(:,2),nodeNum);
nodeRow=ismember(Digraph.Nodes.NodeNumber,nodeNum);

prevOrderNum=Digraph.Nodes.RunOrder{nodeRow}.([splitName '_' splitCode]);

if orderNum==prevOrderNum
    return;
end

% Change the rest of the numbers to avoid duplicates.
% if orderNum<prevOrderNum % Moving to a larger index, subtract one
%     lessThanNewNumIdx=Digraph.Edges.RunOrder<orderNum & Digraph.Edges.RunOrder>prevOrderNum;
%     Digraph.Edges.RunOrder(lessThanNewNumIdx)=Digraph.Edges.RunOrder(lessThanNewNumIdx)-1;
% else % Moving to a smaller index, add one
%     largerThanNewNumIdx=Digraph.Edges.RunOrder>orderNum & Digraph.Edges.RunOrder<prevOrderNum;
%     Digraph.Edges.RunOrder(largerThanNewNumIdx)=Digraph.Edges.RunOrder(largerThanNewNumIdx)+1;
% end

Digraph.Nodes.RunOrder{nodeRow}.([splitName '_' splitCode])=orderNum;

save(projectSettingsMATPath,'Digraph','-append');

if runLog
    desc='Change the order in which the functions are run';
    updateLog(fig,desc,orderNum);
end