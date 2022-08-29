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

% Get the index in the inputVariableNames of the current split. For
% that, need split code corresponding to the current split name
if isempty(handles.Process.splitsUITree.SelectedNodes)
    handles.Process.splitsUITree.SelectedNodes=handles.Process.splitsUITree.Children;
end
text=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(text,' ');
% splitName=text(1:spaceIdx-1);
splitCode=text(spaceIdx+2:end-1); % Currently selected split.

for i=1:length(nodeRowsNums)
    inEdgesRows=ismember(Digraph.Edges.EndNodes(:,2),nodesData(i)); % All inedges for the current function
    if isempty(inEdgesRows)
        beep;
        disp('Need to connect this function to another before selecting it.')
        return;
    end
end

for i=1:length(nodeRowsNums) % Each function

    inEdgesRows=ismember(Digraph.Edges.EndNodes(:,2),nodesData(i)); % All inedges for the current function
    splitCodes=unique(Digraph.Edges.SplitCode(inEdgesRows)); % The list of all splits for the current function

    fcnName=uitreenode(handles.Process.fcnArgsUITree,'Text',Digraph.Nodes.FunctionNames{nodeRowsNums(i)},'NodeData',nodesData(i));
    inputs=uitreenode(fcnName,'Text','Inputs');
    splitIdx=find(ismember(splitCodes,splitCode)==1); % This may be in the wrong order! Organize splits list for each function numerically?

    assert(length(splitIdx)==1);

    for j=1:length(Digraph.Nodes.InputVariableNames{nodeRowsNums(i)}{splitIdx})
        if ~isempty(Digraph.Nodes.InputVariableNames{nodeRowsNums(i)}{splitIdx}{j})
            varAndSplitName=Digraph.Nodes.InputVariableNames{nodeRowsNums(i)}{splitIdx}{j};
            uitreenode(inputs,'Text',varAndSplitName);
        end
    end

    outputs=uitreenode(fcnName,'Text','Outputs');
    for j=1:length(Digraph.Nodes.OutputVariableNames{nodeRowsNums(i)}{splitIdx})
        if ~isempty(Digraph.Nodes.OutputVariableNames{nodeRowsNums(i)}{splitIdx}{j})
            uitreenode(outputs,'Text',Digraph.Nodes.OutputVariableNames{nodeRowsNums(i)}{splitIdx}{j});
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