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

%% Have the user select whether this function is a new branch
branchOpts={'Yes','No'};
[idxYesNo,tf]=listdlg('ListString',branchOpts,'PromptString','Specify whether to create a new branch','SelectionMode','single','Name','New Branch?');

if ~tf
    return;
end

if isequal(branchOpts{idxYesNo},'Yes')
    splitNames=inputdlg('Enter split name','Split name');
    splitNames=splitNames{1};
    while true

        if isempty(splitNames)
            return;
        end

        if isvarname(splitNames)
            break;
        end

        disp(['Split name must be a valid variable name!']);

    end

    coordOffset=[1 -1];

    splitNames=[Digraph.Nodes.SplitNames{idxDigraphFcnNames}; splitName];

else
    splitNames=Digraph.Nodes.SplitNames{idxDigraphFcnNames};
    coordOffset=[0 -1];
end

% Add most node properties
Digraph=addnode(Digraph,1);
Digraph.Nodes.FunctionNames{end}=fcnName;
Digraph.Nodes.Descriptions{end}={''};
Digraph.Nodes.Coordinates(end,:)=Digraph.Nodes.Coordinates(end,:)+coordOffset;
Digraph.Nodes.InputVariableNames{end}={''};
Digraph.Nodes.OutputVariableNames{end}={''};
Digraph.Nodes.SplitNames{end}=splitNames;

nodeNum=size(Digraph.Nodes,1);

% Add edge connections
% First, check if the function is being inserted between an existing edge.
if ismember(idxDigraphFcnNames,Digraph.Edges.EndNodes(:,1))
    befNodeNum=find(ismember(idxDigraphFcnNames,Digraph.Edges.EndNodes(:,1))==1);
    afterNodeNum=Digraph.Edges.EndNodes(befNodeNum,2);
    Digraph=rmedge(Digraph,befNodeNum);
end

% Second, add the new function connection
Digraph=addedge(Digraph,idxDigraphFcnNames,nodeNum);

% Third, reconnect the node after it and move it and all others in this
% line down by 1
if ismember(idxDigraphFcnNames,Digraph.Edges.EndNodes(:,1))
    Digraph=addedge(Digraph,nodeNum,afterNodeNum);
    nodesInCol=find(ismember(Digraph.Nodes.Coordinates(:,2),Digraph.Nodes.Coordinates(nodeNum,2))==1);
    for i=1:length(nodesInCol)

        Digraph.Nodes.Coordinates(nodesInCol(i),2)=Digraph.Nodes.Coordinates(nodesInCol(i),2)-1;

    end
end

plot(handles.Process.mapFigure,Digraph,'XData',Digraph.Nodes.Coordinates(:,1),'YData',Digraph.Nodes.Coordinates(:,2),'NodeLabel',Digraph.Nodes.FunctionNames);

save(projectSettingsMATPath,'Digraph','-append');