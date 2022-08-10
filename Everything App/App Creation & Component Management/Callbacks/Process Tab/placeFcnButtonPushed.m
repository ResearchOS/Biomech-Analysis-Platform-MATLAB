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

setappdata(fig,'placeFcnName',fcnName);

%% Have the user select which function it is building from
projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph');
% digraphFcnNames=Digraph.Nodes.FunctionNames;

% msgbox('First select the origin function node, then select the location to place the new function node. To place between existing nodes, select the existing node as the second location');
% Q=figure; % Plot the digraph on a separate figure to use ginput
xMin=min(Digraph.Nodes.Coordinates(:,1));
yMin=min(Digraph.Nodes.Coordinates(:,2));
xMax=max(Digraph.Nodes.Coordinates(:,1));
yMax=max(Digraph.Nodes.Coordinates(:,2));


% xlims=handles.Process.mapFigure.XLim;
% ylims=handles.Process.mapFigure.YLim;
xlimRange=round(abs(xMax-xMin));
ylimRange=round(abs(yMax-yMin));
% hold on;


iVals=linspace(-2*xlimRange+floor(xMin),ceil(xMax)+xlimRange*2,ceil(xMax)+xlimRange*2-(-2*xlimRange+floor(xMin))+1);
if iVals==0 % Nothing has really been placed yet.
    iVals=[-1 0 1];
end
jVals=linspace(-2*ylimRange+floor(yMin),ceil(yMax)+ylimRange*2,ceil(yMax)+ylimRange*2-(-2*ylimRange+floor(yMin))+1);
if jVals==0
    jVals=[-1 0 1];
end
count=0;
allCoords=NaN(length(iVals)*length(jVals),2);
for i=iVals
    for j=jVals
        count=count+1;
        allCoords(count,:)=[i j];
    end
end

allDigraphCoords=Digraph.Nodes.Coordinates;
allCoords=allCoords(~ismember(allCoords,allDigraphCoords,'rows'),:); % Don't plot dots over existing nodes

% figure(Q);
% fig.CurrentAxes=handles.Process.mapFigure;
% set(0,'CurrentUIFigure',handles.Process.mapFigure);

hold(handles.Process.mapFigure,'on');
allDots=scatter(handles.Process.mapFigure,allCoords(:,1),allCoords(:,2),30,'k','filled');
setappdata(fig,'allDots',allDots);
% Need to change the WindowButtonDownFcn and WindowButtonUpFcn to place a function node at the
% integer-coordinate location nearest to the selected coordinate.
set(fig,'WindowButtonDownFcn',@(fig,event) placeNodeButtonPushed(fig),...
    'WindowButtonUpFcn',@(fig,event) nullButtonUpFcn(fig));