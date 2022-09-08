function []=placeFcnButtonPushed(src,fcnName,currPoint)

%% PURPOSE: PLACE A FUNCTION FROM THE LIST OF FUNCTIONS IN THE PROCESSING FUNCTIONS FOLDER FOR THIS PROJECT INTO THE PROCESSING GUI FIGURE

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Get the list of function names for this project
if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

if ~isempty(getappdata(fig,'allDots'))
    delete(getappdata(fig,'allDots'));
end

setappdata(fig,'allDots','');

% if isempty(handles.Process.splitsUITree.SelectedNodes)
%     disp('Select a split first!');
%     return;
% end

fcnsDir=[getappdata(fig,'codePath') 'Processing Functions' slash];

listing=dir([fcnsDir '*.m']);
fcnNames={listing.name};
[~,idxFcnNamesInFile]=sort(upper(fcnNames));
fcnNames=fcnNames(idxFcnNamesInFile);

%% Have the user select the desired function.
% Also (in the future), add a text area for that function's description
% too.
if exist('fcnName','var')~=1
    label={'Select a function','Only one function can be placed at a time',};
    [idxFcnNamesInFile,tf]=listdlg('ListString',fcnNames,'PromptString',label,'SelectionMode','single','Name','Select function');

    if ~tf
        return;
    end

    fcnName=fcnNames{idxFcnNamesInFile};
    if isequal(fcnName(end-1:end),'.m')
        fcnName=fcnName(1:end-2);
    end
    runLog=true;
else
    runLog=false;
end

setappdata(fig,'placeFcnName',fcnName);

%% Have the user select where to place the fcn
% projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'Digraph');
Digraph=getappdata(fig,'Digraph');

if runLog
    xMin=min(Digraph.Nodes.Coordinates(:,1));
    yMin=min(Digraph.Nodes.Coordinates(:,2));
    xMax=max(Digraph.Nodes.Coordinates(:,1));
    yMax=max(Digraph.Nodes.Coordinates(:,2));

    iVals=linspace(-2+floor(xMin),ceil(xMax)+2,ceil(xMax)+2-(-2+floor(xMin))+1);
    if iVals==0 % Nothing has really been placed yet.
        iVals=[-1 0 1];
    end
    jVals=linspace(-2+floor(yMin),ceil(yMax)+2,ceil(yMax)+2-(-2+floor(yMin))+1);
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

    hold(handles.Process.mapFigure,'on');
    allDots=scatter(handles.Process.mapFigure,allCoords(:,1),allCoords(:,2),30,'k','filled');
    setappdata(fig,'allDots',allDots);

    % Need to change the WindowButtonDownFcn and WindowButtonUpFcn to place a function node at the
    % integer-coordinate location nearest to the selected coordinate.
    set(fig,'WindowButtonDownFcn',@(fig,event) placeNodeButtonPushed(fig),...
        'WindowButtonUpFcn',@(fig,event) nullButtonUpFcn(fig));
%     desc='Clicked place new function node button';
%     updateLog(fig,desc,fcnName,currPoint);
else
    set(fig,'WindowButtonDownFcn',@(fig,event) placeNodeButtonPushed(fig,currPoint),...
        'WindowButtonUpFcn',@(fig,event) nullButtonUpFcn(fig));
end
