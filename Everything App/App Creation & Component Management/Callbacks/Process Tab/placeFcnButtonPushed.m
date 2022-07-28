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
digraphFcnNames=Digraph.Nodes.FunctionNames;

label={'Select the function to place the new function after'};
[idxDigraphFcnNames,tf]=listdlg('ListString',digraphFcnNames,'PromptString',label,'SelectionMode','single','Name','Select placement');

if ~tf
    return;
end

assert(length(unique(idxDigraphFcnNames))==1);
prevFcnName=digraphFcnNames{idxDigraphFcnNames};

%% Have the user select whether this function is a new branch
branchOpts={'Yes','No'};
[idxYesNo,tf]=listdlg('ListString',branchOpts,'PromptString','Specify whether to create a new branch','SelectionMode','single','Name','New Branch?');

if ~tf
    return;
end

if isequal(branchOpts{idxYesNo},'Yes')
    splitName=inputdlg('Enter split name','Split name');
    splitName=splitName{1};
    while true

        if isempty(splitName)
            return;
        end

        if isvarname(splitName)
            break;
        end

        disp(['Split name must be a valid variable name!']);

    end

    coordOffset=[1 -1];

    splitNames=[Digraph.Nodes.SplitNames{idxDigraphFcnNames}; splitName];

    newSplit=1;

else
    splitNames=Digraph.Nodes.SplitNames{idxDigraphFcnNames};
    coordOffset=[0 -1];
    newSplit=0;
end

% Add most node properties
Digraph=addnode(Digraph,1);
Digraph.Nodes.FunctionNames{end}=fcnName;
Digraph.Nodes.Descriptions{end}={''};
Digraph.Nodes.Coordinates(end,:)=Digraph.Nodes.Coordinates(idxDigraphFcnNames,:)+coordOffset;
Digraph.Nodes.InputVariableNames{end}={''};
Digraph.Nodes.OutputVariableNames{end}={''};
Digraph.Nodes.SplitNames{end}=splitNames;

nodeNum=size(Digraph.Nodes,1);

prevNodeIdx=find(ismember(Digraph.Nodes.FunctionNames,prevFcnName)==1);

Digraph=addedge(Digraph,prevNodeIdx,nodeNum); % Add a new edge from the prior node to the new one.

% Add the function names of the new node to the digraph
if ~any(ismember(Digraph.Edges.Properties.VariableNames,'FunctionNames'))
%     Digraph.Edges.FunctionNames={prevFcnName fcnName};
    currEdgeIdx=true; % The row number of the function names for the new edge
else
    currEdgeIdx=cellfun(@isempty,Digraph.Edges.FunctionNames(:,1)); % The row number of the function names for the new edge    
end

Digraph.Edges.FunctionNames{currEdgeIdx,1}=prevFcnName;
Digraph.Edges.FunctionNames{currEdgeIdx,2}=fcnName;

delEdgeIdx=ismember(Digraph.Edges.FunctionNames(:,1),prevFcnName) & ~currEdgeIdx; % The edge to be deleted.

afterNodeNum=Digraph.Edges.EndNodes(delEdgeIdx,2);

currNodeNum=find(ismember(Digraph.Nodes.FunctionNames,fcnName)==1);

if ~isempty(afterNodeNum) && newSplit==0
    Digraph=rmedge(Digraph,Digraph.Edges.EndNodes(delEdgeIdx,1),afterNodeNum); % Delete the edge
    
    Digraph=addedge(Digraph,currNodeNum,afterNodeNum);

    newEdgeIdx=cellfun(@isempty,Digraph.Edges.FunctionNames(:,1)); % The row number of the function names for the new edge    
    Digraph.Edges.FunctionNames{newEdgeIdx,1}=fcnName;
    Digraph.Edges.FunctionNames{newEdgeIdx,2}=Digraph.Nodes.FunctionNames{afterNodeNum};    

end

sameCol=ismember(Digraph.Nodes.Coordinates(:,1),Digraph.Nodes.Coordinates(currNodeNum,1));

belowCoord=Digraph.Nodes.Coordinates(:,2)<=Digraph.Nodes.Coordinates(currNodeNum,2);

nodesInCol=find((sameCol & belowCoord)==1);
nodesInCol(nodesInCol==currNodeNum)=[];

for i=1:length(nodesInCol)
    Digraph.Nodes.Coordinates(nodesInCol(i),2)=Digraph.Nodes.Coordinates(nodesInCol(i),2)-1;
end

plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames);
% axis(handles.Process.mapFigure,'equal');

save(projectSettingsMATPath,'Digraph','-append');