function []=placeFcnButtonPushed(src,event)

%% PURPOSE: PLACE A FUNCTION FROM THE LIST OF FUNCTIONS IN THE PROCESSING FUNCTIONS FOLDER FOR THIS PROJECT INTO THE PROCESSING GUI FIGURE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Get the list of function names for this project
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

fcnsDir=[getappdata(fig,'codePath') 'Processing Functions' slash];

listing=dir([fcnsDir '*.m']);
fcnNames={listing.name};
[~,idxFcnNamesInFile]=sort(upper(fcnNames));
fcnNames=fcnNames(idxFcnNamesInFile);

%% Have the user select the desired function.
% Also (in the future), add a text area for that function's description
% too.
label={'Select a function','Only one function can be placed at a time',};
[idxFcnNamesInFile,tf]=listdlg('ListString',fcnNames,'PromptString',label,'SelectionMode','single','Name','Select function');

if ~tf
    return;
end

fcnName=fcnNames{idxFcnNamesInFile};

if isequal(fcnName(end-1:end),'.m')
    fcnName=fcnName(1:end-2);
end

%% Have the user select which function it is building from
projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');
% digraphFcnNames=Digraph.Nodes.FunctionNames;

% msgbox('First select the origin function node, then select the location to place the new function node. To place between existing nodes, select the existing node as the second location');
Q=figure; % Plot the digraph on a separate figure to use ginput
xlims=handles.Process.mapFigure.XLim;
ylims=handles.Process.mapFigure.YLim;
xlimRange=round(abs(diff(xlims)));
ylimRange=round(abs(diff(ylims)));
% hold on;

count=0;
for i=-2*xlimRange+floor(xlims(1)):ceil(xlims(2))+xlimRange*2
    for j=-2*ylimRange+floor(ylims(1)):ceil(ylims(2))*ylimRange*2
        count=count+1;
        allCoords(count,:)=[i j];
    end
end

figure(Q);
% fig.CurrentAxes=handles.Process.mapFigure;
% set(0,'CurrentUIFigure',handles.Process.mapFigure);
allDots=scatter(allCoords(:,1),allCoords(:,2),30,'k','filled');
plot(Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames);
xlim([min(Digraph.Nodes.Coordinates(:,1)-0.8) max(Digraph.Nodes.Coordinates(:,1)+1.2)]);
ylim([min(Digraph.Nodes.Coordinates(:,2)-1.2) max(Digraph.Nodes.Coordinates(:,2)+0.8)]);
[x,y]=ginput(2);
delete(allDots);
pos=[x y];
tol=0.1;
allDigraphCoords=Digraph.Nodes.Coordinates;
allDigraphDists=sqrt((allDigraphCoords(:,1)-repmat(pos(1,1),size(allDigraphCoords,1),1)).^2+(allDigraphCoords(:,2)-repmat(pos(1,2),size(allDigraphCoords,1),1)).^2);
prevNodeRow=allDigraphDists<tol;

if ~any(prevNodeRow)
    disp('Did not click close enough to a node placement, try again!');
    close(Q);
    return;
end

prevNodeCoord=allDigraphCoords(prevNodeRow,:);
prevFcnName=Digraph.Nodes.FunctionNames{prevNodeRow};
prevNodeID=Digraph.Nodes.NodeNumber(prevNodeRow);
newNodeCoord=round(pos(2,:));

if sqrt(newNodeCoord(1)-pos(2,1).^2+newNodeCoord(2)-pos(2,2).^2)>=tol
    disp('Did not click close enough to a node placement, try again!');
    close(Q);
    return;
end

close(Q);

% Check if creating a new split
coordOffset=newNodeCoord-prevNodeCoord;
splitNames=Digraph.Nodes.SplitNames{prevNodeRow};

if isequal(coordOffset,[1 -1]) % Creating a new split    
    splitName=inputdlg('Enter split name','Split name');
    splitName=splitName{1};
    while true

        if isempty(splitName)
            return;
        end

        if isvarname(splitName)
            uitreenode(handles.Process.splitsUITree,'Text',splitName);
            break;
        end

        disp(['Split name must be a valid variable name!']);

    end

    splitNames=[Digraph.Nodes.SplitNames{prevNodeRow}; splitName];

end

% Add most node properties
afterNodeRow=ismember(Digraph.Nodes.Coordinates,newNodeCoord,'rows'); % Empty if not splitting an existing connection, not empty if being split
afterNodeID=Digraph.Nodes.NodeNumber(afterNodeRow);
if ~isempty(afterNodeID)
    afterNodeFcnName=Digraph.Nodes.FunctionNames{afterNodeRow};
end
Digraph=addnode(Digraph,1);
Digraph.Nodes.FunctionNames{end}=fcnName;
Digraph.Nodes.Descriptions{end}={''};
Digraph.Nodes.Coordinates(end,:)=newNodeCoord;
Digraph.Nodes.InputVariableNames{end}={''};
Digraph.Nodes.OutputVariableNames{end}={''};
Digraph.Nodes.SplitNames{end}=splitNames;
Digraph.Nodes.SpecifyTrials{end}='';
currNodeID=max(Digraph.Nodes.NodeNumber)+1;
Digraph.Nodes.NodeNumber(end)=currNodeID; % Helps to differentiate nodes of the same function name

currNodeRowNum=size(Digraph.Nodes,1);

prevNodeRowNum=find(prevNodeRow==1);

% Add a new edge from the prior node to the new one.
% ADD ONE EDGE FOR EVERY SPLIT FROM THE PRIOR NODE TO THE CURRENT ONE
Digraph=addedge(Digraph,prevNodeRowNum,currNodeRowNum);

% Add the function names of the new node to the digraph
if ~any(ismember(Digraph.Edges.Properties.VariableNames,'FunctionNames'))   
    currEdgeIdx=true; % The row number of the function names for the new edge
else
    currEdgeIdx=ismember(Digraph.Edges.EndNodes,[prevNodeRowNum,currNodeRowNum],'rows');
end

Digraph.Edges.FunctionNames{currEdgeIdx,1}=prevFcnName;
Digraph.Edges.FunctionNames{currEdgeIdx,2}=fcnName;
Digraph.Edges.NodeNumber(currEdgeIdx,1)=prevNodeID;
Digraph.Edges.NodeNumber(currEdgeIdx,2)=currNodeID;

if any(afterNodeRow) % If there is an edge to delete

    Digraph=rmedge(Digraph,prevNodeID,afterNodeID); % Delete the edge

    % ADD ONE EDGE FOR EVERY SPLIT FROM THE PRIOR NODE TO THE CURRENT ONE
    Digraph=addedge(Digraph,currNodeRowNum,afterNodeID); % Add the new one from the current node to the next one

    newEdgeIdx=ismember(Digraph.Edges.EndNodes,[currNodeRowNum afterNodeID],'rows');

    Digraph.Edges.FunctionNames{newEdgeIdx,1}=fcnName;
    Digraph.Edges.FunctionNames{newEdgeIdx,2}=afterNodeFcnName;
    Digraph.Edges.NodeNumber(newEdgeIdx,1:2)=[currNodeID afterNodeID];

    sameCol=ismember(Digraph.Nodes.Coordinates(:,1),Digraph.Nodes.Coordinates(currNodeRowNum,1));

    belowCoord=Digraph.Nodes.Coordinates(:,2)<=Digraph.Nodes.Coordinates(currNodeRowNum,2);

    nodesInCol=find((sameCol & belowCoord)==1);
    nodesInCol(nodesInCol==currNodeRowNum)=[];

    for i=1:length(nodesInCol)
        Digraph.Nodes.Coordinates(nodesInCol(i),2)=Digraph.Nodes.Coordinates(nodesInCol(i),2)-1;
    end

end

plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames);
% axis(handles.Process.mapFigure,'equal');

save(projectSettingsMATPath,'Digraph','-append');