function []=highlightedFcnsChanged(src,Digraph,selNodeNum)

%% PURPOSE: MODIFY THE GUI WITH THE CURRENTLY SELECTED FUNCTIONS' VARIABLES IN fcnArgsUITree
% Inputs:
% src:
% Digraph:
% selNodeNum: The node number for the selected function in the
% fcnArgsUITree. If not entered, use the first function.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

delete(handles.Process.fcnArgsUITree.Children);

selNodeIDs=getappdata(fig,'selectedNodeNumbers'); % From the figure
nodeRows=ismember(Digraph.Nodes.NodeNumber,selNodeIDs);
nodesData=Digraph.Nodes.NodeNumber(nodeRows);
nodeRowsNums=find(nodeRows==1);

for i=1:length(nodeRowsNums)

    fcnName=uitreenode(handles.Process.fcnArgsUITree,'Text',Digraph.Nodes.FunctionNames{nodeRowsNums(i)},'NodeData',nodesData(i));
    inputs=uitreenode(fcnName,'Text','Inputs');
    for j=1:length(Digraph.Nodes.InputVariableNames{nodeRowsNums(i)})
        if ~isempty(Digraph.Nodes.InputVariableNames{nodeRowsNums(i)}{j})
            uitreenode(inputs,'Text',Digraph.Nodes.InputVariableNames{nodeRowsNums(i)}{j});
        end
    end
    outputs=uitreenode(fcnName,'Text','Outputs');
    for j=1:length(Digraph.Nodes.OutputVariableNames{nodeRowsNums(i)})
        if ~isempty(Digraph.Nodes.OutputVariableNames{nodeRowsNums(i)}{j})
            uitreenode(outputs,'Text',Digraph.Nodes.OutputVariableNames{nodeRowsNums(i)}{j});
        end
    end

    if i==1 && exist('selNodeNum','var')==0
        handles.Process.fcnArgsUITree.SelectedNodes=fcnName;
    end

    if exist('selNodeNum','var')==1
        handles.Process.fcnArgsUITree.SelectedNodes=fcnName;
    end

end

functionsUITreeSelectionChanged(fig);
% handles.Process.fcnDescriptionTextArea=Digraph.Nodes.Descriptions{nodeRows};