function []=connectNodesButtonPushedWindowButtonDown(src,event)

%% PURPOSE: CONNECT TWO NODES WITH AN EDGE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

connectNodesCoords=getappdata(fig,'connectNodesCoords');

if all(isnan(connectNodesCoords),'all')
    rowNum=1;
else
    rowNum=2;
end

if ~isequal(handles.Tabs.tabGroup1.SelectedTab.Title,'Process')
    return;
end

if isempty(fig.CurrentObject)
    return;
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

xlims=handles.Process.mapFigure.XLim;
ylims=handles.Process.mapFigure.YLim;

currPoint=handles.Process.mapFigure.CurrentPoint;

currPoint=currPoint(1,1:2);

connectNodesCoords(rowNum,1:2)=currPoint;

if currPoint(1)<xlims(1) || currPoint(1)>xlims(2) || currPoint(2)<ylims(1) || currPoint(2)>ylims(2)
    setappdata(fig,'connectNodesCoords',NaN(2,2));
    setappdata(fig,'doNothingOnButtonUp',0); % Allows functions to be highlighted as normal.
    set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
    'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));
%     disp('Clicked outside of the axes');
    return; % Clicked outside of the axes
end

setappdata(fig,'connectNodesCoords',connectNodesCoords);

if rowNum==1
    return; % First click
end

setappdata(fig,'connectNodesCoords',NaN(2,2));

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
Digraph=getappdata(fig,'Digraph');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');
% load(projectSettingsMATPath,'Digraph','NonFcnSettingsStruct');

digraphCoords=Digraph.Nodes.Coordinates;
digraphDists1=sqrt((digraphCoords(:,1)-repmat(connectNodesCoords(1,1),size(digraphCoords,1),1)).^2+(digraphCoords(:,2)-repmat(connectNodesCoords(1,2),size(digraphCoords,1),1)).^2);
digraphDists2=sqrt((digraphCoords(:,1)-repmat(connectNodesCoords(2,1),size(digraphCoords,1),1)).^2+(digraphCoords(:,2)-repmat(connectNodesCoords(2,2),size(digraphCoords,1),1)).^2);

[~,idx1]=min(digraphDists1);
[~,idx2]=min(digraphDists2);

if isequal(idx1,idx2)
    disp('Cannot connect a node to itself!');
    setappdata(fig,'connectNodesCoords',NaN(2,2));
    setappdata(fig,'doNothingOnButtonUp',0);
    set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
    'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));
    return;
end

sp=shortestpath(Digraph,idx1,idx2);

splitsOrder=getSplitsOrder(handles.Process.splitsUITree.SelectedNodes,handles.Process.splitsUITree.Tag);
if isempty(splitsOrder)
    return;
end

splitsStruct=NonFcnSettingsStruct.Process.Splits;
for i=1:length(splitsOrder)
    splitsStruct=splitsStruct.SubSplitNames.(splitsOrder{i});
end
color=splitsStruct.Color;

splitText=handles.Process.splitsUITree.SelectedNodes.Text;
spaceIdx=strfind(splitText,' ');
splitName=splitText(1:spaceIdx-1);
splitCode=splitText(spaceIdx+2:end-1);

% Check whether an existing split (not the current one) is already using
% this color.
if any(ismember(Digraph.Edges.Color,color) & ~ismember(Digraph.Edges.SplitCode,splitCode))
    disp(['You are attempting to create an edge with split (' splitCode ') for the first time!']);
    disp('However, another split already has the same color.');
    disp('Please delete this split and re-create it with another color!');
    return;
end

if ~isempty(sp) || isequal(sp,[idx1 idx2])
    prevConnectedRows=ismember(Digraph.Edges.EndNodes,[idx1 idx2],'rows');
    if ismember(color,Digraph.Edges.Color(prevConnectedRows,:),'rows')
        disp('Nodes already connected with this split!'); % Redundant connections allowed between neighboring nodes only
        setappdata(fig,'connectNodesCoords',NaN(2,2));
        setappdata(fig,'doNothingOnButtonUp',0);
        set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
            'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));
        return;
    end
end

nodeID1=Digraph.Nodes.NodeNumber(idx1,:);
nodeID2=Digraph.Nodes.NodeNumber(idx2,:);

if isempty(Digraph.Edges)    
    newDigraph=digraph;
    for i=1:size(Digraph.Nodes,1)
        newDigraph=addnode(newDigraph,Digraph.Nodes(i,:));        
    end
    Digraph=newDigraph;
end

Digraph=addedge(Digraph,idx1,idx2);   

if ~any(ismember(Digraph.Edges.Properties.VariableNames,'FunctionNames'))
    currEdgeIdx=true; % The row number of the function names for the new edge
else
    currEdgeIdx=ismember(Digraph.Edges.EndNodes,[idx1,idx2],'rows') & cellfun(@isempty, Digraph.Edges.FunctionNames(:,1));
end

assert(sum(currEdgeIdx)==1);

Digraph.Edges.FunctionNames{currEdgeIdx,1}=Digraph.Nodes.FunctionNames{idx1};
Digraph.Edges.FunctionNames{currEdgeIdx,2}=Digraph.Nodes.FunctionNames{idx2};
Digraph.Edges.NodeNumber(currEdgeIdx,1)=nodeID1;
Digraph.Edges.NodeNumber(currEdgeIdx,2)=nodeID2;
Digraph.Edges.Color(currEdgeIdx,:)=color;
Digraph.Edges.SplitCode{currEdgeIdx}=splitCode;

% Add the new split to Digraph.Nodes.InputVariableNames &
% Digraph.Nodes.OutputVariableNames
if isempty(Digraph.Nodes.InputVariableNames{idx2}) % First connection to this node.
    Digraph.Nodes.InputVariableNames{idx2}=struct([splitName '_' splitCode],'');
    Digraph.Nodes.InputVariableNamesInCode{idx2}=struct([splitName '_' splitCode],'');
    Digraph.Nodes.RunOrder{idx2}=struct([splitName '_' splitCode],0);
else % Create more fields for input vars for each new split.
    varNames=Digraph.Nodes.InputVariableNames{idx2};
    varNamesInCode=Digraph.Nodes.InputVariableNamesInCode{idx2};
    runOrders=Digraph.Nodes.RunOrder{idx2};
    if ~isfield(varNames,[splitName '_' splitCode])
        varNames.([splitName '_' splitCode])='';
        varNamesInCode.([splitName '_' splitCode])='';
        runOrders.([splitName '_' splitCode])=0;
        Digraph.Nodes.InputVariableNames{idx2}=varNames;
        Digraph.Nodes.InputVariableNamesInCode{idx2}=varNamesInCode;
        Digraph.Nodes.RunOrder{idx2}=runOrders;
    end
end

if isempty(Digraph.Nodes.OutputVariableNames{idx1})
    Digraph.Nodes.OutputVariableNames{idx1}=struct([splitName '_' splitCode],'');
    Digraph.Nodes.OutputVariableNamesInCode{idx1}=struct([splitName '_' splitCode],'');
    Digraph.Nodes.RunOrder{idx1}=struct([splitName '_' splitCode],0);
else
    varNames=Digraph.Nodes.OutputVariableNames{idx1};
    varNamesInCode=Digraph.Nodes.OutputVariableNamesInCode{idx1};
    runOrders=Digraph.Nodes.RunOrder{idx1};
    if ~isfield(varNames,[splitName '_' splitCode])
        varNames.([splitName '_' splitCode])='';
        varNamesInCode.([splitName '_' splitCode])='';
        runOrders.([splitName '_' splitCode])=0;
        Digraph.Nodes.OutputVariableNames{idx1}=varNames;
        Digraph.Nodes.OutputVariableNamesInCode{idx1}=varNamesInCode;
        Digraph.Nodes.RunOrder{idx1}=runOrders;
    end
end

%% Get the row number for the selected nodes
node1RowNum=find(ismember(Digraph.Nodes.NodeNumber,nodeID1)==1);
node2RowNum=find(ismember(Digraph.Nodes.NodeNumber,nodeID2)==1);

%% If these nodes already have splits, prompt the user to ask which split to copy the variables from.
% Closing out of that window will select to not copy the variables
Q=uifigure('Name','Select split to copy variables from');
Qhandles.uitree=uitree(Q,'checkbox','Tag','Tree');
okbox=uibutton(Q,'push','Text','OK','Position',[450 200 100 50],'ButtonPushedFcn',@(Q,event) okButtonPushedSplits(Q));
Qhandles.okbox=okbox;
setappdata(Q,'handles',Qhandles);

rootTag='Stop';
rootNode=uitreenode(Qhandles.uitree,'Text','Root (Not a Split)','Tag',rootTag);

splits=NonFcnSettingsStruct.Process.Splits;
getSplitNames(splits,[],rootNode);
uiwait(Q);
try
    selSplit=evalin('base','selSplit;'); % 1st entry is the root split, last entry is the split to copy the variables from.
    copyVars=1;
    evalin('base','clear selSplit;');
    selSplit=selSplit(~ismember(selSplit,'Root'));
    if isempty(selSplit)
        copyVars=0;
    end
catch
    copyVars=0;
%     return; % The process was aborted.
end

if copyVars==0 % No split was chosen
    %% Plot the new connection
    delete(handles.Process.mapFigure.Children);
    h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.447 0.741],'Interpreter','none');
    h.EdgeColor=Digraph.Edges.Color;
   
    setappdata(fig,'Digraph',Digraph);

    setappdata(fig,'doNothingOnButtonUp',0);
    set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
        'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));
    return;
end

for i=1:length(selSplit)
    splits=splits.SubSplitNames.(selSplit{i});
end

splitCodePrev=splits.Code;
splitNamePrev=splits.Name{1};

%% Get the list of all nodes in the current split.
newSplitEdgesIdx=ismember(Digraph.Edges.SplitCode,splitCode);
newSplitNodeNumbers=unique(reshape(Digraph.Edges.NodeNumber(newSplitEdgesIdx,:),size(Digraph.Edges.NodeNumber(newSplitEdgesIdx,:),1)*2,1));

%% Copy the prior variables to the new split
% Copy the input variables for the first node being connected
prevInputVarsNode1=Digraph.Nodes.InputVariableNames{node1RowNum}.([splitNamePrev '_' splitCodePrev]);
for i=1:length(prevInputVarsNode1)
    % Check all other functions in this split to see if this input variable
    % was an output variable. If so, change the split to the current split.
    % If not, leave it as the original split name.
    for j=1:length(newSplitNodeNumbers)

        if ismember(prevInputVarsNode1{i},Digraph.Nodes.OutputVariableNames{newSplitNodeNumbers(j)}.([splitNamePrev '_' splitCodePrev]))
            prevInputVarsNode1{i}=strrep(prevInputVarsNode1{i},splitCodePrev,splitCode);
            break; % Stop looking for matches for this input variable.
        end

    end

end
Digraph.Nodes.InputVariableNames{node1RowNum}.([splitName '_' splitCode])=prevInputVarsNode1;
Digraph.Nodes.InputVariableNamesInCode{node1RowNum}.([splitName '_' splitCode])=Digraph.Nodes.InputVariableNamesInCode{node1RowNum}.([splitNamePrev '_' splitCodePrev]);
 
% Output variables of the first node being connected.
prevOutputVarsNode1=Digraph.Nodes.OutputVariableNames{node1RowNum}.([splitNamePrev '_' splitCodePrev]);
for i=1:length(prevOutputVarsNode1)
    prevOutputVarsNode1{i}=strrep(prevOutputVarsNode1{i},splitCodePrev,splitCode);
end
Digraph.Nodes.OutputVariableNames{node1RowNum}.([splitName '_' splitCode])=prevOutputVarsNode1;
Digraph.Nodes.OutputVariableNamesInCode{node1RowNum}.([splitName '_' splitCode])=Digraph.Nodes.OutputVariableNamesInCode{node1RowNum}.([splitNamePrev '_' splitCodePrev]);

% Input variables of the second node being connected.
prevInputVarsNode2=Digraph.Nodes.InputVariableNames{node2RowNum}.([splitNamePrev '_' splitCodePrev]);
for i=1:length(prevInputVarsNode2)
    % Check all other functions in this split to see if this input variable
    % was an output variable. If so, change the split to the current split.
    % If not, leave it as the original split name.
    for j=1:length(newSplitNodeNumbers)

        if ismember(prevInputVarsNode2{i},Digraph.Nodes.OutputVariableNames{newSplitNodeNumbers(j)}.([splitNamePrev '_' splitCodePrev]))
            prevInputVarsNode2{i}=strrep(prevInputVarsNode2{i},splitCodePrev,splitCode);
            break; % Stop looking for matches for this input variable.
        end

    end

end
Digraph.Nodes.InputVariableNames{node2RowNum}.([splitName '_' splitCode])=prevInputVarsNode2;
Digraph.Nodes.InputVariableNamesInCode{node2RowNum}.([splitName '_' splitCode])=Digraph.Nodes.InputVariableNamesInCode{node2RowNum}.([splitNamePrev '_' splitCodePrev]);

% Output variables of the second node being connected.
prevOutputVarsNode2=Digraph.Nodes.OutputVariableNames{node2RowNum}.([splitNamePrev '_' splitCodePrev]);
for i=1:length(prevOutputVarsNode2)
    prevOutputVarsNode2{i}=strrep(prevOutputVarsNode2{i},splitCodePrev,splitCode);
end
Digraph.Nodes.OutputVariableNames{node2RowNum}.([splitName '_' splitCode])=prevOutputVarsNode2;
Digraph.Nodes.OutputVariableNamesInCode{node2RowNum}.([splitName '_' splitCode])=Digraph.Nodes.OutputVariableNamesInCode{node2RowNum}.([splitNamePrev '_' splitCodePrev]);

%% Plot the new connection
delete(handles.Process.mapFigure.Children);
h=plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames,'NodeColor',[0 0.447 0.741],'Interpreter','none');
h.EdgeColor=Digraph.Edges.Color;

% save(projectSettingsMATPath,'Digraph','-append');
setappdata(fig,'Digraph',Digraph);

setappdata(fig,'doNothingOnButtonUp',0);
set(fig,'WindowButtonDownFcn',@(fig,event) windowButtonDownFcn(fig),...
    'WindowButtonUpFcn',@(fig,event) windowButtonUpFcn(fig));